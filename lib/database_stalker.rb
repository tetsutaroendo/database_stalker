require "database_stalker/version"
require "database_stalker/parser"

module DatabaseStalker

  DEFAULT_LOG_FILE = 'log/test.log'
  DEFAULT_TABLE_LOG_FILE = 'log/table_names.log'

  class  << self

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
