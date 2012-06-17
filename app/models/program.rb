class Program < ActiveRecord::Base
  attr_accessor :file
  belongs_to :user
  accepts_nested_attributes_for :user
  attr_accessible :user_id, :name, :file_name, :arguments_file_name, :size, :lines, :number_of_levels, :number_of_runs, :file, :arguments_file
end
