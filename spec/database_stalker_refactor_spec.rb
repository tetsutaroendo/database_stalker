require 'spec_helper'
require 'database_stalker'

describe DatabaseStalker do
  before do
    clean_up_file(test_log)
    clean_up_file(table_log)
    clean_up_file(stalking_log)
    clean_up_file(stalking_log_per_test)
    kill_all_tail_process
    set_up_previous_test_log
  end

  after do
    clean_up_file(test_log)
    clean_up_file(table_log)
    clean_up_file(stalking_log)
    clean_up_file(stalking_log_per_test)
    kill_all_tail_process
  end

  let(:test_log) { 'spec/fixture/test.log' }
  let(:table_log) { 'spec/fixture/table.log' }
  let(:stalking_log) { 'spec/fixture/stalked_copy.log' }
  let(:stalking_log_per_test) { 'spec/fixture/stalked_copy_per_test.log' }

  it do
    fork do
      $stderr = File.open("/dev/null", "w")
      described_class.set_up(test_log: test_log, table_log: table_log, stalking_log: stalking_log)
      described_class.stalk
      logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
      logger.sync = true
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example2` (`id`) VALUES (1)\n")
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example3` (`id`) VALUES (1)\n")
      logger.close
      crash # simulate test process dies
    end
    sleep(10)
    described_class.set_up(test_log: test_log, table_log: table_log)
    expect(described_class.table_names).to eq(['example2', 'example3'])
  end

  it do
    described_class.set_up(test_log: test_log, table_log: table_log, stalking_log: stalking_log, stalking_log_per_test: stalking_log_per_test)
    described_class.stalk_per_test
    logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
    logger.sync = true
    logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example2` (`id`) VALUES (1)\n")
    logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example3` (`id`) VALUES (1)\n")
    logger.close
    expect(described_class.table_names_per_test).to eq(['example2', 'example3'])
  end

  private

    def set_up_previous_test_log
      logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
      logger.sync = true
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example1` (`id`) VALUES (1)\n")
      logger.close
    end
end
