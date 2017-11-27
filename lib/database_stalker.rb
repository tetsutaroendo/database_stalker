require 'database_stalker/version'
require 'database_stalker/parser'
require 'database_stalker/log_stalker'

module DatabaseStalker

  DEFAULT_LOG_FILE = 'log/test.log'
  DEFAULT_TABLE_LOG_FILE = 'log/table_names.log'
  DEFAULT_STALKING_LOG_FILE = 'log/stalking_log.log'
  DEFAULT_STALKING_LOG_PER_TEST_FILE = 'log/stalking_log_per_test.log'

  class  << self

    def set_up(
      test_log: DEFAULT_LOG_FILE,
      table_log: DEFAULT_TABLE_LOG_FILE,
      stalking_log: DEFAULT_TABLE_LOG_FILE,
      stalking_log_per_test: DEFAULT_STALKING_LOG_PER_TEST_FILE)
      @test_log = test_log
      @table_log = table_log
      @stalking_log = stalking_log
      @stalking_log_per_test = stalking_log_per_test
    end

    def stalk
      fork do
        log_stalker = LogStalker.new(@test_log, @stalking_log)
        log_stalker.run
        watch_test_process
        log_stalker.stop
        appended_log = log_stalker.result
        parser = Parser.new(appended_log)
        File.open(@table_log, 'w') do |file|
          parser.table_names.each do |table_name|
            file.write("#{table_name}\n")
          end
        end
      end
      sleep(3)
    end

    def table_names
      result = []
      File.open(@table_log, 'r') do |f|
        f.each_line do |line|
          result << line.strip
        end
      end
      result
    end

    def stalk_per_test
      @log_stalker = LogStalker.new(@test_log, @stalking_log)
      @log_stalker.run
    end

    def table_names_per_test
      @log_stalker.stop
      appended_log = @log_stalker.result
      parser = Parser.new(appended_log)
      parser.table_names
    end

    def start(log_file: DEFAULT_LOG_FILE, table_log_file: DEFAULT_TABLE_LOG_FILE)
      clean_up_file(log_file) if File.exist?(log_file)
      Process.fork do
        watch_test_process
        save_stalked_tables(log_file, table_log_file)
      end
    end

    def read_table_names(table_log_file: DEFAULT_TABLE_LOG_FILE)
      return [] if not File.exist?(table_log_file)
      result = []
      File.open(table_log_file, 'r') do |f|
        f.each_line do |line|
          result << line.strip
        end
      end
      result
    end

    def clean_up_file(file)
      File.open(file,'w'){ |f| f = nil }
    end

    def save_stalked_tables(log_file, table_log_file)
      File.open(table_log_file, 'w') do |f|
        if File.exist?(log_file)
          parser = Parser.new(log_file)
          parser.table_names.each { |table| f.puts table }
        else
          f = nil
        end
      end
    end

    def watch_test_process
      while true
        return if Process.ppid == 1
      end
    end
  end

  private_class_method :save_stalked_tables, :watch_test_process, :clean_up_file
end
