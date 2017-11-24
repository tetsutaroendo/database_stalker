require 'spec_helper'
require 'logger'
require 'database_stalker/log_stalker'

module DatabaseStalker
  describe LogStalker do
    before do
      described_class.kill_all_stalker
      clean_up_file(stalked_file_path)
      clean_up_file(stalking_result_path)
    end

    let(:stalked_file_path) { 'spec/fixture/stalked.log' }
    let(:stalking_result_path) { 'spec/fixture/stalked_copy.log' }
    let(:logger) {
      logger = open(stalked_file_path, (File::WRONLY | File::APPEND | File::CREAT))
      logger.sync = true
      logger
    }

    it do
      File.open(stalked_file_path, 'w') do |f|
        f.puts "existing log\n"
      end
      stalker = described_class.new(stalked_file_path, stalking_result_path)
      stalker.run
      logger.write("log1\n")
      logger.write("log2\n")
      logger.write("log3\n")
      stalker.stop
      expect(stalker.result).to eq(["log1\n", "log2\n", "log3\n"])
    end

    after do
      described_class.kill_all_stalker
      logger.close
      clean_up_file(stalked_file_path)
      clean_up_file(stalking_result_path)
    end
  end
end
