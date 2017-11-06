require "spec_helper"
require 'database_stalker/parser'

describe DatabaseStalker::Parser do
  let(:test_log_path) { 'spec/fixture/test.log' }

  before { clean_up_file(test_log_path) }

  subject do
    write_file(test_log_path, log)
    parser = described_class.new(test_log_path)
    parser.table_names
  end

  context 'テーブルが複数' do
    let(:log) do
      <<-EOS
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples1` (`id`) VALUES (1)
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples2` (`id`) VALUES (1)
      EOS
    end

    it { is_expected.to eq(['examples1', 'examples2']) }
  end

  context '無駄な行を含む' do
    let(:log) do
      <<-EOS
  [1m[35m (0.2ms)[0m  BEGIN
  [1m[36m (0.1ms)[0m  [1mSAVEPOINT active_record_1[0m
  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples` (`id`) VALUES (1)
  [1m[36m (0.1ms)[0m  [1mRELEASE SAVEPOINT active_record_1[0m
      EOS
    end

    it { is_expected.to eq(['examples']) }
  end

  after { clean_up_file(test_log_path) }
end
