class RunPoint < ActiveRecord::Base
  attr_accessible :mem_size, :program_id, :run_id, :run_time, :run_type_id, :user_id
end
