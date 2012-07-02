class RunPoint < ActiveRecord::Base
  attr_accessible :program_id, :mem_size, :run_time, :run_type_id, :level_number
  has_one :run_type
  belongs_to :program
  
  validates :mem_size, :presence => true
  validates :program_id, :presence => true
  validates :run_time, :presence => true
  validates :run_type_id, :presence => true
  validates :level_number, :presence => true
end
