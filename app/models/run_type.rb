class RunType < ActiveRecord::Base
  attr_accessible :description, :name
  belongs_to :run_point
  
  GHC = RunType.find(1)
  GHC_O2 = RunType.find(2)
  SUPER = RunType.find(3)
  SUPER_O2 = RunType.find(4)
  DISTILL = RunType.find(5)
  DISTILL_O2 = RunType.find(6)
end
