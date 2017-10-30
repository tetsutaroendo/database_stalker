require "database_stalker/version"

module DatabaseStalker

  def self.start(log_file, table_log_file)
   main_pid = Process.pid
    Process.fork do
      thread = Process.detach(main_pid)
      while true
        break if thread.status == false
      end
      File.open(table_log_file, 'w') do |f|
      end
    end
  end
end
