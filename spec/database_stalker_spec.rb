require "spec_helper"

describe DatabaseStalker do
  context 'version' do
    it { expect(DatabaseStalker::VERSION).not_to be nil }
  end

  describe 'functions' do
    before do
      File.delete(test_log_path) if File.exists?(test_log_path)
      File.delete(table_log_path) if File.exists?(table_log_path)
    end
    let(:test_log_path) { 'spec/fixture/test.log' }
    let(:table_log_path) { 'spec/fixture/table.log' }

    it do
      described_class.start(test_log_path, table_log_path)
      File.open(test_log_path, 'w') do |f|
            log = <<-EOS
    [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples1` (`id`) VALUES (1)
    [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples2` (`name`) VALUES ('NAME')
            EOS
          f.puts log
      end
      result = nil
      File.open(table_log_path, 'r') do |f|
        f.each_line do |line|
          result = line
        end
      end
      expect(result).to be_nil
    end

    after do
      File.delete(test_log_path) if File.exists?(test_log_path)
      File.delete(table_log_path) if File.exists?(table_log_path)
    end
  end
end
