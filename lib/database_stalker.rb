require 'database_stalker/version'
require 'database_stalker/parser'
require 'database_stalker/log_stalker'

module DatabaseStalker

  DEFAULT_LOG_FILE = 'log/test.log'
  DEFAULT_TABLE_LOG_FILE = 'log/table_names.log'
  DEFAULT_STALKING_LOG_FILE = 'log/stalking_log.log'
  DEFAULT_STALKING_LOG_PER_TEST_FILE = 'log/stalking_log_per_test.log'
  DEFAULT_STALKING_LOG_PER_TEST_TEMPORARY_FILE = 'log/stalking_log_per_test_temporary.log'

  class  << self

    def set_up(
      test_log: DEFAULT_LOG_FILE,
      table_log: DEFAULT_TABLE_LOG_FILE,
      stalking_log: DEFAULT_STALKING_LOG_FILE,
      stalking_log_per_test: DEFAULT_STALKING_LOG_PER_TEST_FILE,
      stalking_log_per_test_temporary: DEFAULT_STALKING_LOG_PER_TEST_TEMPORARY_FILE)
      @test_log = test_log
      @table_log = table_log
      @stalking_log = stalking_log
      @stalking_log_per_test = stalking_log_per_test
      @stalking_log_per_test_temporary = stalking_log_per_test_temporary
      File.delete(@stalking_log_per_test_temporary) if File.exist?(@stalking_log_per_test_temporary)
      FileUtils.touch(@stalking_log_per_test_temporary)
    end

    def stalk
      fork do
        log_stalker = LogStalker.new(@test_log, @stalking_log)
        log_stalker.run
        watch_test_process
        log_stalker.stop
        used_log = []
        File.open(@stalking_log_per_test_temporary, 'r') do |f|
          f.each_line do |line|
            used_log << line
          end
        end
        all_log = log_stalker.result
        parser = Parser.new(all_log.slice(used_log.size .. all_log.size - 1))
        File.open(@table_log, 'w') do |file|
          parser.table_names.each do |table_name|
            file.write("#{table_name}\n")
          end
        end
      end
      wait_for_log_stalker
    end

    def wait_for_log_stalker
      sleep(0.1)
    end

    def table_names
      return [] if not File.exists?(@table_log)
      result = []
      File.open(@table_log, 'r') do |f|
        f.each_line do |line|
          result << line.strip
        end
      end
      result
    end

    def stalk_per_test
      @log_stalker = LogStalker.new(@test_log, @stalking_log_per_test)
      @log_stalker.run
    end

    def table_names_per_test
      @log_stalker.stop
      appended_log = @log_stalker.result
      parser = Parser.new(appended_log)
      parser.table_names
    end

    def notify_table_deletion
      File.open(@stalking_log_per_test_temporary, 'a') do |file|
        appended_log = @log_stalker.result
        appended_log.each do |line|
          file.puts("#{line}")
        end
      end
    end

    def watch_test_process
      while true
        return if Process.ppid == 1
      end
    end
  end

  private_class_method :watch_test_process, :wait_for_log_stalker
end
