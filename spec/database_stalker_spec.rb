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

    context 'test log already has some data' do
      it do
        write_file(test_log_path, 'some data')
        allow(Process).to receive(:ppid).and_return(1)
        described_class.start(test_log_path, table_log_path)
        expect(table_names_from_log(test_log_path)).to be_empty
        simulate_test_process_dies
      end
    end

    context 'test.log do not exist' do
      it do
        allow(Process).to receive(:ppid).and_return(1)
        described_class.start(test_log_path, table_log_path)
        simulate_test_process_dies
        expect(File.exist?(test_log_path)).to be_falsy
        expect(table_names_from_log(table_log_path)).to be_empty
      end
    end

    context 'mocking test process' do
      it do
        allow(Process).to receive(:ppid).and_return(1)
        described_class.start(test_log_path, table_log_path)
        simulate_db_operation(test_log_path)
        simulate_test_process_dies
        expect(File.exists?(table_log_path)).to be_truthy
      end
    end

    context 'simulate test process' do
      it do
        Process.fork do
          described_class.start(test_log_path, table_log_path)
          simulate_db_operation(test_log_path)
          $stderr = File.open("/dev/null", "w")
          crash # simulate test process dies
        end
        wait_test_process_simulation
        expect(File.exists?(table_log_path)).to be_truthy
      end
    end

    after do
      clean_up_file(test_log_path)
      clean_up_file(table_log_path)
    end
  end

  private

    def simulate_db_operation(log_path)
      log = <<-EOS
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples` (`id`) VALUES (1)
      EOS
      write_file(log_path, log)
    end

    def table_names_from_log(log_path)
      result = []
      File.open(log_path, 'r') do |f|
        f.each_line do |line|
          result << line.strip
        end
      end
      result
    end

    def simulate_test_process_dies
      sleep(2)
    end

    def wait_test_process_simulation
      sleep(2)
    end
end
