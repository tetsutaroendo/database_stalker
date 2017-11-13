require 'spec_helper'
require 'open3'

xdescribe 'collaboratation with rails' do
  before { clean_up_file(path_to_tables_log) }

  let(:current_directory) { Dir.pwd }
  let(:path_to_tables_log) { 'rails_test/spec/tables.log' }

  it do
    execute_test_of_rails_application
    sleep(2)
    expect(File.exists?(path_to_tables_log)).to be_truthy
  end

  after { clean_up_file(path_to_tables_log) }

  private

    def execute_test_of_rails_application
      Open3.capture3("cd rails_test && bundle exec rspec -I../lib spec/database_stalker_usage_spec.rb")
    end
end
