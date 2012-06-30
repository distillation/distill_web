class Program < ActiveRecord::Base
  belongs_to :user
  has_many :run_points, :through => :run
  accepts_nested_attributes_for :user
  attr_accessible :user_id, :name, :normal_file_name, :normal_file_contents, :arguments_file_name, :number_of_levels, :number_of_runs, :file, :arguments_file_contents, :arguments
  attr_accessible :super_file_contents, :distill_file_contents
  validates :user_id, :presence => true
  validates :name, :presence => true
  validates :number_of_levels, :presence => true
  validates :number_of_runs, :presence => true
  validates :file, :presence => true
  validates :arguments, :presence => true
  attr_accessor :file, :arguments
  
  @queue = :bencmarks_queue
  
  FILE_SIZE_CMD = "ls -la PATH | awk '{print $5}'"
  
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

  def self.perform(id)
    puts "here"
    @program = Program.find(id)
    @program.generate_run_points
  end
  
  def self.naive_reverse_code
    NAIVE_REVERSE.gsub("\n","\r")
  end
  
  def self.arguments_code
    ARGUMENTS.gsub("\n","\r")
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
    puts 'calling'
    Resque.enqueue(Program, self.id.to_s)
  end
  
  def levels
    (1..self.number_of_levels).to_a
  end
  
  def average_mem_size_by_level_id_and_run_type_id(level_id, run_type_id)
    avg = 0
    run_points = self.run_points.find_all_by_level_id_and_run_type_id(level_id, run_type_id)
    run_points.each do |rp|
      avg += rp.mem_size
    end
    avg / run_points.length
  end
  
  def average_run_time_by_level_id_and_run_type_id(level_id, run_type_id)
    avg = 0.0
    run_points = self.run_points.find_all_by_level_id_and_run_type_id(level_id, run_type_id)
    run_points.each do |rp|
      avg += rp.run_time
    end
    avg / run_points.length
  end
  
  def generate_run_points
    #transformation dirs
    program_dir = Program::PROGRAMS_DIR + self.id.to_s + "/"

    normal_dir = program_dir + 'normal/'
    super_dir = program_dir + 'super/'
    distill_dir = program_dir + 'distill/'

    Dir.mkdir(program_dir)
    [normal_dir, super_dir, distill_dir].each do |folder|
      Dir.mkdir(folder)
    end
    
    #get executable name
    chomped_file_name = Program.get_chomped_file_name(self.normal_file_name)

    #inputs for all transformations
    normal_file = normal_dir + self.normal_file_name
    super_file = super_dir + self.normal_file_name
    distill_file = distill_dir + self.normal_file_name
    
    #executables for all transformations
    normal_obj = normal_dir + chomped_file_name
    super_obj = super_dir + chomped_file_name
    distill_obj = distill_dir + chomped_file_name
    
    #write arguments for all transformations
    [normal_dir, super_dir, distill_dir].each do |dir|
      File.open(dir + self.arguments_file_name, 'w') do |file|
        file.write(self.arguments_file_contents)
        file.close
      end
    end 
    
    #write initial benchmark
    File.open(normal_file, 'w') do |file|
      file.write(self.normal_file_contents)
      file.close
    end

    #transform orignal with super & distill
    super_in, super_out, super_err = Open3.popen3("#{Haskell.transformer} super #{normal_file}")
    #distill_in, distill_out, distill_err = Open.popen3("#{Haskell.transformer} distill #{normal_file}")
    #benchmark original, super & distill @program.number_of_levels times
    #write benchmark values to db
    #benchmark original
    
    #compile all
    `#{Haskell.path} --make #{normal_file} -i#{normal_dir} -rtsopts`
    `#{Haskell.path} --make #{super_file} -i#{super_dir} -rtsopts`
    #`#{Haskell.path} --make #{distill_file} -i#{distill_dir} -rtsopts` 
    
    puts "No of Runs: " + self.number_of_runs.to_s
    self.number_of_runs.times do |i|
      puts "Run: " + i.to_s
      self.number_of_levels.times do |level|
        level += 1
        @run_point = RunPoint.new
        puts "Level: " + level.to_s
        rpin, rpout, rperr = Open3.popen3("#{normal_obj} #{level.to_s} +RTS -sstderr")
        output = rperr.read
        output =~ /^.+\n (.+) MB total.+$/
        puts $1
      end
    end
  end
end
