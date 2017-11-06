require "database_stalker/version"

module DatabaseStalker

  def self.start(log_file, table_log_file)
    Process.fork do
      while true
        break if Process.ppid == 1
      end
      tables = ['examples1', 'examples2']
      File.open(table_log_file, 'w') do |f|
        tables.each { |table| f.puts table }
      end
    end
  end
end
