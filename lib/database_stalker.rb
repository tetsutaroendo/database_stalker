require "database_stalker/version"
require "database_stalker/parser"

module DatabaseStalker

  def self.start(log_file, table_log_file)
    Process.fork do
      while true
        break if Process.ppid == 1
      end
      File.open(table_log_file, 'w') do |f|
        parser = Parser.new(log_file)
        parser.table_names.each { |table| f.puts table }
      end
    end
  end
end
