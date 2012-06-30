# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

run_types = RunType.create([{:id => 1, :name => 'GHC',          :description => 'Standard version compiled with GHC'},
                            {:id => 2, :name => 'GHC -O2',      :description => 'Standard version compiled with GHC -O2'},
                            {:id => 3, :name => 'Super',        :description => 'Supercompiled version compiled with GHC'},
                            {:id => 4, :name => 'Super -O2',    :description => 'Supercompiled version compiled with GHC -O2'},
                            {:id => 5, :name => 'Distill',      :description => 'Distilled version compiled with GHC'},
                            {:id => 6, :name => 'Distill -O2',  :description => 'Distilled version compiled with GHC -O2'}])
