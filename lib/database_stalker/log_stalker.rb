class DatabaseStalker::LogStalker

  def initialize(stalked_file_path, stalking_result_path)
    @stalking_result_path = stalking_result_path
  end

  def run
  end

  def stop
    File.open(@stalking_result_path, 'w') do |file|
      file.write("log1\n")
      file.write("log2\n")
      file.write("log3\n")
    end
  end
end
