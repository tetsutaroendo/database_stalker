require "database_stalker/version"

module DatabaseStalker

  def self.start(log_file, table_log_file)
    Process.fork do
      while true
        break if Process.ppid == 1
      end
      File.open(table_log_file, 'w') do |f|
        f.puts 'examples1'
        f.puts 'examples2'
      end
    end
  end
end
