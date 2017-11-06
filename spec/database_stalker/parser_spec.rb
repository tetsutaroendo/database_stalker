require "spec_helper"
require 'database_stalker/parser'

describe DatabaseStalker::Parser do
  let(:test_log_path) { 'spec/fixture/test.log' }

  before do
    clean_up_file(test_log_path)
  end

  it do
    log = <<-EOS
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples1` (`id`) VALUES (1)
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples2` (`id`) VALUES (1)
    EOS
    simulate_db_operation(test_log_path, log)
    parser = described_class.new(test_log_path)
    expect(parser.table_names).to eq(['examples1', 'examples2'])
  end

  after do
    clean_up_file(test_log_path)
  end

  private

  def simulate_db_operation(log_path, log)
    File.open(log_path, 'w') do |f|
      f.puts log
    end
  end

  def clean_up_file(file_path)
    File.delete(file_path) if File.exists?(file_path)
  end

end
