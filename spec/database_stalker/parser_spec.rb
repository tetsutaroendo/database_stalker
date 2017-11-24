require "spec_helper"
require 'database_stalker/parser'

describe DatabaseStalker::Parser do
  subject do
    parser = described_class.new(log)
    parser.table_names
  end

  context 'multiple inserted tables' do
    let(:log) do
      [
        "  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples1` (`id`) VALUES (1)\n",
        "  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples2` (`id`) VALUES (1)\n",
      ]
    end

    it { is_expected.to eq(['examples1', 'examples2']) }
  end

  context 'other log inclusion' do
    let(:log) do
      [
        "  [1m[35m (0.2ms)[0m  BEGIN\n",
        "  [1m[36m (0.1ms)[0m  [1mSAVEPOINT active_record_1[0m\n",
        "  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples` (`id`) VALUES (1)\n",
        "  [1m[36m (0.1ms)[0m  [1mRELEASE SAVEPOINT active_record_1[0m\n",
      ]
    end

    it { is_expected.to eq(['examples']) }
  end

  context 'table name duplication' do
    let(:log) do
      [
        "  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples` (`id`) VALUES (1)\n",
        "  [1m[35mSQL (0.4ms)[0m  INSERT INTO `examples` (`id`) VALUES (2)\n",
      ]
    end

    it { is_expected.to eq(['examples']) }
  end
end
