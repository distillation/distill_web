class Program < ActiveRecord::Base
  belongs_to :user
  has_one :run
  accepts_nested_attributes_for :user
  attr_accessible :user_id, :name, :file_name, :arguments_file_name, :number_of_levels, :number_of_runs, :file, :arguments_file, :arguments, :folder_name
  validates :user_id, :presence => true
  validates :name, :presence => true
  validates :file_name, :presence => true
  validates :arguments_file_name, :presence => true
  validates :number_of_levels, :presence => true
  validates :number_of_runs, :presence => true
  attr_accessor :file, :arguments, :folder_name, :file_name, :arguments_file_name
  
  FILES_ROOT = Rails.root.to_s + "/public/"
  PROGRAMS_DIR = FILES_ROOT + "programs/"
  
  NAIVE_REVERSE = <<-END
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
    NAIVE_REVERSE
  end
  
  def self.arguments_code
    ARGUMENTS
  end
  
  def self.get_chomped_file_name(file_name)
    file_name.chomp('.hs')
  end
  
  def set_folder_name(file)
    @folder_name = Program.get_chomped_file_name(file)
    if File.directory?(PROGRAMS_DIR + @folder_name)
      i = 1
      while File.directory?(PROGRAMS_DIR + @folder_name + i.to_s)
        i += 1
      end
      @folder_name << i.to_s
    end 
    @folder_name << '/'
  end
  
  def save_file!(uploaded_file, arguments_file)
    set_folder_name(uploaded_file.original_filename)
    @file_name = uploaded_file.original_filename
    @arguments_file_name = arguments_file.original_filename
    
    program_dir = PROGRAMS_DIR + @folder_name
    Dir.mkdir(program_dir)
    
    normal_file_hs = program_dir + @file_name
    arguments_file_hs = program_dir + @arguments_file_name
    
    File.open(normal_file_hs, 'w') { |file|
      file.write(uploaded_file.read)
      file.close
    }
    
    File.open(arguments_file_hs, 'w') do |file|
      file.write(arguments_file.read)
      file.close
    end
  end
  
  def compiles?
    normal_file_hs = PROGRAMS_DIR + @folder_name + @file_name
    normal_object = PROGRAMS_DIR + @folder_name + Program.get_chomped_file_name(@file_name)
    compile = `#{Haskell.path} --make #{normal_file_hs} -i#{Program::PROGRAMS_DIR + @folder_name}`
    File.exist?(normal_object)
  end
  
  def remove_files!
    FileUtils.rm_rf(PROGRAMS_DIR + @folder_name)
  end
end
