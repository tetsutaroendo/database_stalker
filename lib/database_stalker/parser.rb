class DatabaseStalker::Parser
  def initialize(log)
    @log = log
  end

  def table_names
    tables = []
    @log.each do |line|
      matched = line.match(/INSERT\ INTO\ `(.+)` \(/)
      tables << matched[1] unless matched.nil?
    end
    tables.uniq
  end
end
