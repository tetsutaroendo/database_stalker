require 'spec_helper'
require 'database_stalker'

describe DatabaseStalker do
  before do
    clean_up
    set_up_previous_test_log
  end

  after do
    clean_up
  end

  let(:test_log) { 'spec/fixture/test.log' }
  let(:table_log) { 'spec/fixture/table.log' }
  let(:stalking_log) { 'spec/fixture/stalked_copy.log' }
  let(:stalking_log_per_test) { 'spec/fixture/stalked_copy_per_test.log' }
  let(:stalking_log_per_test_temporary) { 'spec/fixture/stalked_copy_per_test_temporary.log' }

  describe 'table name extraction in test process' do
    context 'test process is crash' do
      it do
        fork do
          $stderr = File.open("/dev/null", "w")
          logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
          logger.sync = true
          set_up_tested_class
          described_class.stalk
          logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example1` (`id`) VALUES (1)\n")
          logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example2` (`id`) VALUES (1)\n")
          logger.close
          crash # simulate test process dies
        end
        wait_for_test_process
        set_up_tested_class
        expect(described_class.table_names).to eq(['example1', 'example2'])
      end
    end

  context 'with per test'
    it 'can extract table name before notify_table_deletion was called' do
      fork do
        $stderr = File.open("/dev/null", "w")
        logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
        logger.sync = true
        set_up_tested_class
        described_class.stalk
        described_class.stalk_per_test
        logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example1` (`id`) VALUES (1)\n")
        described_class.table_names_per_test
        described_class.notify_table_deletion

        logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example2` (`id`) VALUES (1)\n")
        logger.close
        crash # simulate test process dies
      end
      wait_for_test_process
      set_up_tested_class
      expect(described_class.table_names).to eq(['example2'])
    end
  end

  describe 'table name extraction per test method' do
    it do
      set_up_tested_class
      logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
      logger.sync = true
      described_class.stalk_per_test
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example1` (`id`) VALUES (1)\n")
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example2` (`id`) VALUES (1)\n")
      logger.close
      expect(described_class.table_names_per_test).to eq(['example1', 'example2'])
    end

    it 'does not include previous table name' do
      set_up_tested_class
      logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
      logger.sync = true

      described_class.stalk_per_test
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example1` (`id`) VALUES (1)\n")
      described_class.table_names_per_test

      described_class.stalk_per_test
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example2` (`id`) VALUES (1)\n")
      logger.close
      expect(described_class.table_names_per_test).to eq(['example2'])
    end

    describe 'table name  acquirement' do
      context 'table name log does not exist' do
        it do
          set_up_tested_class
          expect(described_class.table_names).to be_empty
        end
      end
    end
  end

  private

    def set_up_tested_class
      described_class.set_up(test_log: test_log, table_log: table_log, stalking_log: stalking_log, stalking_log_per_test: stalking_log_per_test, stalking_log_per_test_temporary: stalking_log_per_test_temporary)
    end

    def wait_for_test_process
      sleep(1)
    end

    def clean_up
      clean_up_file(test_log)
      clean_up_file(table_log)
      clean_up_file(stalking_log)
      clean_up_file(stalking_log_per_test)
      clean_up_file(stalking_log_per_test_temporary)
      kill_all_tail_process
    end

    def set_up_previous_test_log
      logger = open(test_log, (File::WRONLY | File::APPEND | File::CREAT))
      logger.sync = true
      logger.write("  [0m[0mSQL (0.0ms)[0m  INSERT INTO `example` (`id`) VALUES (1)\n")
      logger.close
    end
end
