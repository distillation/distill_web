# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

run_types = RunType.create([{:name => 'GHC',          :description => 'Standard version compiled with GHC'},
                            {:name => 'GHC -O2',      :description => 'Standard version compiled with GHC -O2'},
                            {:name => 'Super',        :description => 'Supercompiled version compiled with GHC'},
                            {:name => 'Super -O2',    :description => 'Supercompiled version compiled with GHC -O2'},
                            {:name => 'Distill',      :description => 'Distilled version compiled with GHC'},
                            {:name => 'Distill -O2',  :description => 'Distilled version compiled with GHC -O2'}])
