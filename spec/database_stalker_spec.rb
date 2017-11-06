require "spec_helper"

describe DatabaseStalker do
  context 'version' do
    it { expect(DatabaseStalker::VERSION).not_to be nil }
  end

  describe 'functions' do
    before do
      clean_up_file(test_log_path)
      clean_up_file(table_log_path)
    end

    let(:test_log_path) { 'spec/fixture/test.log' }
    let(:table_log_path) { 'spec/fixture/table.log' }

    context 'test process ends as normal' do
      it do
        allow(Process).to receive(:ppid).and_return(1)
        described_class.start(test_log_path, table_log_path)
        File.open(test_log_path, 'w') do |f|
              log = <<-EOS
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples1` (`id`) VALUES (1)
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples2` (`id`) VALUES (1)
              EOS
            f.puts log
        end
        wait_for_process_lifecicle

        result = []
        File.open(table_log_path, 'r') do |f|
          f.each_line do |line|
            result << line.strip
          end
        end
        expect(result).to eq(['examples1', 'examples2'])
      end
    end

    after do
      clean_up_file(test_log_path)
      clean_up_file(table_log_path)
    end
  end

  private

    def clean_up_file(file_path)
      File.delete(file_path) if File.exists?(file_path)
    end

    def wait_for_process_lifecicle
      sleep(2)
    end
end
