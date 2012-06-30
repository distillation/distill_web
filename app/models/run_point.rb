class RunPoint < ActiveRecord::Base
  attr_accessible :mem_size, :program_id, :run_id, :run_time, :run_type_id, :user_id, :level_id
  has_one :run_type
  belongs_to :program
  
  validates :mem_size, :presence => true
  validates :program_id, :presence => true
  validates :run_id, :presence => true
  validates :run_time, :presence => true
  validates :run_type_id, :presence => true
  validates :user_id, :presence => true
end
