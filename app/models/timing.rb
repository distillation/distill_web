class Timing < ActiveRecord::Base
  belongs_to :user
  belongs_to :program
  
  attr_accessible :arguments, :user_id, :distill_02_time, :distill_O2_compile, :distill_O2_mem, :distill_compile, :distill_mem, :distill_time, :normal_O2_compile, :normal_O2_mem, :normal_O2_time, :normal_compile, :normal_mem, :normal_time, :program_id, :super_O2_compile, :super_O2_mem, :super_O2_time, :super_compile, :super_mem, :super_time
  
  FILES_ROOT = Rails.root.to_s + "/public/files/"
  INPUT_DIR = FILES_ROOT + "inputs/"
  SUPER_DIR = FILES_ROOT + "super/" 
  DISTILL_DIR = FILES_ROOT + 'distill/'
  TEST_CASE_DIR = FILES_ROOT + "/testcases/"
  
  def chomped_file_name
    return @chomped_file_name if defined?(@chomped_file_name)
    @chomped_file_name = self.program.file_name.chomp(File.extname(self.program.file_name))
  end
  
  def timing_file_name
    TEST_CASE_DIR + chomped_file_name + @id.to_s
  end
  
  def time_normal(o2=false)    
    timing_normal_obj = timing_file_name
    timing_normal_file = timing_file_name + '.hs'
    
    normal_file = INPUT_DIR + self.program.file_name
    normal_file_args = File.read(normal_file) + "\n\n" + self.arguments
    
    File.open (timing_normal_file, 'w') do |f|
      f.write (normal_file_args)
      f.close
    end
    
    compile_time, execution_time, execution_mem = get_timings(timing_normal_file, timing_normal_obj, "normal", o2)
    return false unless compile_time

    unless o2
      self.normal_compile = compile_time
      self.normal_time = execution_time
      self.normal_mem = execution_mem
    else
      self.normal_O2_compile = compile_time
      self.normal_O2_time = execution_time
      self.normal_O2_mem = execution_mem
    end
    true    
  end
  
  def time_supercompiled(o2=false)
    timing_super_obj = timing_file_name + '_super'
    timing_super_file = timing_file_name + '_super.hs'
    
    super_file = SUPER_DIR + self.program.file_name
    super_file_args = File.read(super_file) + "\n\n" + self.arguments
    
    File.open (timing_super_file, 'w') do |f|
      f.write (super_file_args)
      f.close
    end
    
    compile_time, execution_time, execution_mem = get_timings(timing_super_file, timing_super_obj, "super", o2)
    return false unless compile_time

    unless o2
      self.super_compile = compile_time
      self.super_time = execution_time
      self.super_mem = execution_mem
    else
      self.super_O2_compile = compile_time
      self.super_O2_time = execution_time
      self.super_O2_mem = execution_mem
    end
    true
  end
  
  def time_distilled
  end
  
  def get_timings(timing_file, timing_obj, type, o2=false)
    now = Time.now
    `#{Haskell.path} --make #{"-O2" if o2} #{timing_file} -rtsopts`
    compile_time = Time.now - now
    
    return False unless File.exists?(timing_obj)
    
    #TODO: record output.
    output = `#{timing_obj} +RTS -sstderr 2> #{TEST_CASE_DIR}#{type}_#{chomped_file_name}_err.txt`
    err = File.read(TEST_CASE_DIR + "#{type}_" + @chomped_file_name + '_err.txt')
    err =~ /^.*Total time(.*)s.*\(.*$/
    execution_time = $1.to_f.to_s
    err =~ /^.*\n(.*)MB total.*$/
    execution_mem = $1.to_i
    
    File.delete(timing_file)
    File.delete(timing_obj)
    File.delete("#{TEST_CASE_DIR}#{type}_#{chomped_file_name}_err.txt")
    
    [compile_time, execution_time, execution_mem]
  end
end