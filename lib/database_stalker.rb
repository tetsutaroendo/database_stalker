require "database_stalker/version"

module DatabaseStalker

  def self.start(log_file, table_log_file)
    File.open(table_log_file, 'w') do |f|
    end
  end
end
