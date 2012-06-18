class Run < ActiveRecord::Base
  attr_accessible :distill_compile_time, :distill_size, :ghc_compile_time, :ghc_size, :program_id, :super_compile_time, :super_size, :user_id
end
