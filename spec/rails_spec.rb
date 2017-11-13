require 'spec_helper'
require 'open3'
require 'bundler'

describe 'collaboratation with rails' do
  before { clean_up_file(table_log_file) }

  let(:table_log_file) { 'rails_test/log/table_names.log' }

  it do
    execute_test_of_rails_application
    sleep(2)
    expect(DatabaseStalker.read_table_names(table_log_file: table_log_file)).to match_array(['sample1s', 'sample2s', 'sample3s'])
  end

  after { clean_up_file(table_log_file) }

  private

    def execute_test_of_rails_application
      Bundler.with_clean_env do
        Open3.capture3("cd rails_test && bundle exec rspec -I../lib spec/database_stalker_usage_spec.rb")
      end
    end
end
