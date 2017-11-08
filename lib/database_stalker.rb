require "database_stalker/version"
require "database_stalker/parser"

module DatabaseStalker

  class  << self

    def start(log_file, table_log_file)
      File.open(log_file,'w'){ |f| f = nil }
      Process.fork do
        watch_test_process
        save_stalked_tables(log_file, table_log_file)
      end
    end

    def save_stalked_tables(log_file, table_log_file)
      File.open(table_log_file, 'w') do |f|
        parser = Parser.new(log_file)
        parser.table_names.each { |table| f.puts table }
      end
    end

    def watch_test_process
      while true
        return if Process.ppid == 1
      end
    end
  end

  private_class_method :save_stalked_tables, :watch_test_process
end
