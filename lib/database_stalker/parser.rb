class DatabaseStalker::Parser
  def initialize(log_file)
    @log_file = log_file
  end

  def table_names
    tables = []
    File.open(@log_file, 'r') do |f|
      f.each_line do |line|
        matched = line.match(/INSERT\ INTO\ `(.+)` \(/)
        tables << matched[1] unless matched.nil?
      end
    end
    tables
  end
end
