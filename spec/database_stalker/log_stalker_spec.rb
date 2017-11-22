require 'spec_helper'
require 'database_stalker/log_stalker'

module DatabaseStalker
  describe LogStalker do
    before do
      clean_up_file(stalked_file_path)
      clean_up_file(stalking_result_path)
    end

    let(:stalked_file_path) { 'spec/fixture/stalked.log' }
    let(:stalking_result_path) { 'spec/fixture/stalked_copy.log' }
    let(:logger) { open(stalked_file_path, 'a') }

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
      result = []
      File.open(stalking_result_path) do |file|
        file.each_line do |line|
          result << line
        end
      end
      expect(result).to eq(["log1\n", "log2\n", "log3\n"])
    end
    after { logger.close }
  end
end
