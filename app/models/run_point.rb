class RunPoint < ActiveRecord::Base
  attr_accessible :mem_size, :program_id, :run_id, :run_time, :run_type_id, :user_id
  has_one :run_type
  belongs_to :run
  belongs_to :user, :through => :run
end
