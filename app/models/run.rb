class Run < ActiveRecord::Base
  attr_accessible :distill_compile_time, :distill_size, :ghc_compile_time, :ghc_size, :program_id, :super_compile_time, :super_size, :user_id, :program, :user, :level_number
  has_many :run_point
  belongs_to :program
  belongs_to :user
    
  @queue = :benchmarks_queue
  
  FILE_SIZE_CMD = "ls -la PATH | awk '{print $5}'"
  
  def self.perform(id, level)
    @run = Run.new
    @run.program = Program.find(id)
    @run.level = level.to_i
    @run.generate_run_points
  end
  
  def generate_run_points
    #transformation dirs
    program_dir = Program::PROGRAMS_DIR + self.program.id.to_s + "/"

    normal_dir = program_dir + 'normal/'
    super_dir = program_dir + 'super/'
    distill_dir = program_dir + 'distill/'

    Dir.mkdir(program_dir)
    [normal_dir, super_dir, distill_dir].each do |folder|
      Dir.mkdir(folder)
    end
    
    #get executable name
    chomped_file_name = Program.get_chomped_file_name(self.program.normal_file_name)

    #inputs for all transformations
    normal_file = normal_dir + self.program.normal_file_name
    super_file = super_dir + self.program.normal_file_name
    distill_file = distill_dir + self.program.normal_file_name
    
    #executables for all transformations
    normal_obj = normal_dir + chomped_file_name
    super_obj = super_dir + chomped_file_name
    distill_obj = distill_dir + chomped_file_name
    
    #write arguments for all transformations
    [normal_dir, super_dir, distill_dir].each do |dir|
      File.open(dir + self.program.arguments_file_name, 'w') do |file|
        file.write(self.program.arguments_file_contents)
        file.close
      end
    end 
    
    #write initial benchmark
    File.open(normal_file, 'w') do |file|
      file.write(self.program.normal_file_contents)
      file.close
    end

    #transform orignal with super & distill
    super_in, super_out, super_err = Open3.popen3("#{Haskell.transformer} super #{normal_file}")
    #distill_in, distill_out, distill_err = Open.popen3("#{Haskell.transformer} distill #{normal_file}")
    #benchmark original, super & distill @program.number_of_levels times
    #write benchmark values to db
    #benchmark original
    
    #compile all
    now = Time.now
    `#{Haskell.path} --make #{normal_file} -i#{normal_dir}`
    self.ghc_compile_time = Time.now - now
    self.ghc_size = `#{FILE_SIZE_CMD.gsub('PATH', normal_obj)}`.to_i
    
    now = Time.now
    `#{Haskell.path} --make #{super_file} -i#{super_dir}`
    self.super_compile_time = Time.now - now
    self.super_size = `#{FILE_SIZE_CMD.gsub('PATH', super_obj)}`.to_i
    self.save
    puts self.inspect
    #`#{Haskell.path} --make #{distill_file} -i#{distill_dir}` 
    
    self.program.number_of_runs.times do
        puts level_number.to_s
    end
  end
end
