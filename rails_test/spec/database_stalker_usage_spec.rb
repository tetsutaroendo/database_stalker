require 'spec_helper'
require 'database_stalker'

describe 'use database_stakler' do
  before :all do
  end

  it do
    DatabaseStalker.set_up
    DatabaseStalker.stalk
    DatabaseStalker.stalk_per_test
    Sample1.create!
    Sample2.create!
    DatabaseStalker.table_names_per_test
    DatabaseStalker.notify_table_deletion
    Sample3.create!
  end
end
