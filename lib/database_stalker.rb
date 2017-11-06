require "database_stalker/version"

module DatabaseStalker

  def self.start(log_file, table_log_file)
    Process.fork do
      while true
        break if Process.ppid == 1
      end
      tables = []
      File.open(log_file, 'r') do |f|
        f.each_line do |line|
          matched = line.match(/INSERT\ INTO\ `(.+)` \(/)
          tables << matched[1]
          #tables << matched[1] unless matched.nil?
        end
      end
      File.open(table_log_file, 'w') do |f|
        tables.each { |table| f.puts table }
      end
    end
  end
end
