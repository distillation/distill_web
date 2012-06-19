class Run < ActiveRecord::Base
  attr_accessible :distill_compile_time, :distill_size, :ghc_compile_time, :ghc_size, :program_id, :super_compile_time, :super_size, :user_id
  has_many :run_point
  belongs_to :program
  belongs_to :user
  validates :distill_compile_time, :presence => true
  validates :distill_size, :presence => true
  validates :ghc_compile_time, :presence => true
  validates :ghc_size, :presence => true
  validates :super_compile_time, :presence => true
  validates :super_size, :presence => true
  validates :program_id, :presence => true
  validates :user_id, :presence => true
end
