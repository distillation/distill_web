class Program < ActiveRecord::Base
  belongs_to :user
  has_many :run
  accepts_nested_attributes_for :user
  attr_accessible :user_id, :name, :normal_file_name, :normal_file_contents, :arguments_file_name, :number_of_levels, :number_of_runs, :file, :arguments_file_contents, :arguments, :folder_name, :super_file_contents
  attr_accessible :distill_file_contents
  validates :user_id, :presence => true
  validates :name, :presence => true
  validates :number_of_levels, :presence => true
  validates :number_of_runs, :presence => true
  validates :file, :presence => true
  validates :arguments, :presence => true
  attr_accessor :file, :arguments
  
  FILES_ROOT = Rails.root.to_s + "/public/"
  PROGRAMS_DIR = FILES_ROOT + "programs/"
  
  ERROR_REGEX = /.+\/(.+\.hs.*\n.+)/
  
  NAIVE_REVERSE = 
<<-END
module Main where
import System.Environment (getArgs)
  import Arguments
    
  main = do
    args <- getArgs
    let level = read (head args) :: Int
    print $ root (randomXS level)
    
  root = \\xs -> nrev xs
    
  nrev = \\xs -> case xs of
    [] -> []
    (y:ys) -> app (nrev ys) [y]
    
  app = \\xs ys -> case xs of
    [] -> ys
    (z:zs) -> (z:app zs ys)
  END
  
  ARGUMENTS = <<-END
    module Arguments where
  
  randomXS = \\level -> case level of
    1 -> [1..10]
    2 -> [10..100]
    3 -> [100..1000]
  END
  
  def self.naive_reverse_code
    "module Main where\r\rimport System.Environment (getArgs)\rimport Arguments\r\rmain = do\r  args <- getArgs\r  let level = read (head args) :: Int\r  print $ root (randomXS level)\r\r" +
    "root = \\xs -> nrev xs\r\rnrev = \\xs -> case xs of\r  [] -> []\r  (y:ys) -> app (nrev ys) [y]\r\rapp = \\xs ys -> case xs of\r  [] -> ys\r  (z:zs) -> (z:app zs ys)"
  end
  
  def self.arguments_code
    "module Arguments where\r\rrandomXS = \\level -> case level of\r  1 -> [1..10]\r  2 -> [10..100]\r  3 -> [100..1000]"
  end
  
  def self.get_chomped_file_name(file_name)
    file_name.chomp('.hs')
  end
  
  def save_file!(uploaded_file, arguments_file)
    self.normal_file_name = uploaded_file.original_filename
    self.arguments_file_name = arguments_file.original_filename

    program_dir = PROGRAMS_DIR + folder_name
    Dir.mkdir(program_dir)
    
    normal_file_hs = program_dir + self.normal_file_name
    arguments_file_hs = program_dir + self.arguments_file_name
    
    self.normal_file_contents = uploaded_file.read
    self.arguments_file_contents = arguments_file.read
    
    File.open(normal_file_hs, 'w') do |file|
      file.write(self.normal_file_contents)
      file.close
    end
    
    File.open(arguments_file_hs, 'w') do |file|
      file.write(self.arguments_file_contents)
      file.close
    end
  end
  
  def folder_name
    (self.id.nil? ? (Program.count + 1) : self.id).to_s + '/'
  end
   
  def compiles?
    normal_file_hs = PROGRAMS_DIR + folder_name + self.normal_file_name
    normal_object = PROGRAMS_DIR + folder_name + Program.get_chomped_file_name(self.normal_file_name)
    
    sin, sout, serr = Open3.popen3("#{Haskell.path} --make #{normal_file_hs} -i#{Program::PROGRAMS_DIR + self.folder_name}")
    error = serr.read

    unless error.empty? #only do this if there's no error
      error =~ ERROR_REGEX
      self.errors[:base] << "Your program didn't compile\nThe compiler error was:\n#{$1.to_s}"
    end
    remove_files!
    error.empty?
  end
  
  def remove_files!
    FileUtils.rm_rf(PROGRAMS_DIR + folder_name + '/')
  end
  
  def asynch_benchmark_program
    self.number_of_levels.times do |i|
      Resque.enqueue(Run, self.id.to_s, (i + 1).to_s)
    end
  end
end
