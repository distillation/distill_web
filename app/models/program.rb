class Program < ActiveRecord::Base
  belongs_to :user
  has_many :run_points
  
  accepts_nested_attributes_for :user
  
  attr_accessible :user_id, :name, :normal_file_name, :normal_file_contents
  attr_accessible :arguments_file_name, :number_of_levels, :number_of_runs, :file, :arguments_file_contents, :arguments
  attr_accessible :super_file_contents, :distill_file_contents, :run_points
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
  
  MEM_SIZE_REGEX = /^.+\n (.+) MB total.+$/
  RUN_TIME_REGEX = /^.*Total.*time.*\( (.*s) elapsed\)$/
  
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
  
  def remove_files!(fn=folder_name)
    FileUtils.rm_rf(PROGRAMS_DIR + fn + '/')
  end
  
  def asynch_benchmark_program
    Resque.enqueue(Program, self.id.to_s)
  end
  
  def levels
    (1..self.number_of_levels).to_a
  end
  
  def average_mem_size_by_level_id_and_run_type_id(level_id, run_type_id)
    avg = 0
    puts "here" + level_id.to_s + " " + run_type_id.to_s
    rps = self.run_points.find_all_by_level_number_and_run_type_id(level_id, run_type_id)
    puts "here"
    puts rps.inspect
    rps.each do |rp|
      avg += rp.mem_size
    end
    return 0 if rps.empty?
    avg / rps.length
  end
  
  def average_run_time_by_level_id_and_run_type_id(level_id, run_type_id)
    avg = 0.0
    run_points = self.run_points.find_all_by_level_number_and_run_type_id(level_id, run_type_id)
    run_points.each do |rp|
      avg += rp.run_time
    end
    avg / run_points.length
  end
  
  def self.perform(id)
    @program = Program.find(id)
    RunType.all.each do |rt|
      puts rt.name
      @program.generate_run_points_for_run_type(rt)
    end
  end
  
  def generate_run_points_for_run_type(run_type)
    program_dir = Program::PROGRAMS_DIR + self.id.to_s + "/"
    transformation_dir = program_dir + run_type.folder_name + "/"

    Dir.mkdir(program_dir) unless File.exists?(program_dir)
    Dir.mkdir(transformation_dir)
    
    chomped_file_name = Program.get_chomped_file_name(self.normal_file_name)
    file = transformation_dir + self.normal_file_name
    obj = transformation_dir + chomped_file_name
    
    File.open(transformation_dir + self.arguments_file_name, 'w') do |f|
      f.write(self.arguments_file_contents)
      f.close
    end 
    
    File.open(file, 'w') do |f|
      f.write(self.normal_file_contents)
      f.close
    end
    unless (run_type.transformation_name.nil?)
      t_in, t_out, t_err = Open3.popen3("#{Haskell.transformer} #{run_type.transformation_name} #{file} #{run_type.transformation_name}")
      if (run_type.transformation_name.eql?("super"))
        File.open("#{obj}#{run_type.transformation_name.to_s}.hs") do |f|
          self.update_attribute(:super_file_contents, f.read)
          f.close
        end
      elsif(run_type.transformation_name.eql?("distill"))
        File.open("#{obj}#{run_type.transformation_name.to_s}.hs") do |f|
          self.update_attribute(:distill_file_contents, f.read)
          f.close
        end
        self.save
      end
    end 
    c_in, c_out, c_err = Open3.popen3("#{Haskell.path} --make #{run_type.options.to_s} #{obj}#{run_type.transformation_name.to_s}.hs -i#{transformation_dir} -rtsopts")
    sleep(60)
    perform_runs_for_run_type(obj, run_type)
  end
  
  def perform_runs_for_run_type(obj_path, run_type)
    self.number_of_runs.times do |i|
      self.number_of_levels.times do |level|
        level += 1
        
        rin, rerr, rstat = Open3.capture3("#{obj_path}#{run_type.transformation_name.to_s} #{level.to_s} +RTS -sstderr")
        run_point = RunPoint.new
        run_point.program_id = self.id
        run_point.run_type_id = run_type.id
        rerr =~ MEM_SIZE_REGEX
        run_point.mem_size = $1.to_i
        rerr =~ RUN_TIME_REGEX
        run_point.run_time = $1.to_f
        run_point.level_number = level
        run_point.save
      end
    end
  end
end
