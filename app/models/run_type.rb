class RunType < ActiveRecord::Base
  attr_accessible :description, :name
  belongs_to :run_point
end
