class Program < ActiveRecord::Base
  attr_accessor :file
  belongs_to :user
  has_many :timings
  accepts_nested_attributes_for :user
  attr_accessible :lines, :file_name, :name, :size, :user_id, :file
end
