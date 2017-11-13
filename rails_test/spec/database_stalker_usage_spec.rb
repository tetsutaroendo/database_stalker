require 'database_stalker'

describe 'use database_stakler' do
  it do
    DatabaseStalker.start('./log/test.log', './spec/tables.log')
    Sample1.create!
    Sample2.create!
    Sample3.create!
  end
end
