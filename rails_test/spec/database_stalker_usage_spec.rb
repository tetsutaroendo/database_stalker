require 'spec_helper'
require 'database_stalker'

describe 'use database_stakler' do
  it do
    DatabaseStalker.start
    Sample1.create!
    Sample2.create!
    Sample3.create!
  end
end
