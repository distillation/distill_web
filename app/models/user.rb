class User < ActiveRecord::Base
  acts_as_authentic
  attr_accessible :username, :email, :password, :password_confirmation
  has_many :programs
  has_many :runs
  has_many :run_points, :through => :runs 
  #validations taken care of by authlogic
end
