class RunType < ActiveRecord::Base
  attr_accessible :description, :name, :folder_name, :options
  belongs_to :run_point
  
  GHC = RunType.find_by_name('GHC')
  GHC_O2 = RunType.find_by_name('GHC -O2')
  SUPER = RunType.find_by_name('Super')
  SUPER_O2 = RunType.find_by_name('Super -O2')
  DISTILL = RunType.find_by_name('Distill')
  DISTILL_O2 = RunType.find_by_name('Distill -O2')
end
