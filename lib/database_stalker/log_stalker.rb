require 'open3'

class DatabaseStalker::LogStalker

  def initialize(stalked_file_path, stalking_result_path)
    @stalked_file_path = stalked_file_path
    @stalking_result_path = stalking_result_path
  end

  def run
    @runned_tails = self.class.runned_tail_pids
    spawn("tail -f -n 0 #{@stalked_file_path} > #{@stalking_result_path}")
    wait_for_tail_process_runninng
  end

  def stop
    wait_for_tail_process_output
    current_runned_tails = self.class.runned_tail_pids
    (current_runned_tails - @runned_tails).each do |pid|
      Process.kill('KILL', pid)
    end
  end

  def result
    result = []
    File.open(@stalking_result_path) do |file|
      file.each_line do |line|
        result << line
      end
    end
    result
  end

  def self.kill_all_stalker
    runned_tail_pids.each do |pid|
      Process.kill('KILL', pid)
    end
  end

  def self.runned_tail_pids
    pids = ''
    IO.popen("ps -e | grep 'tail -f -n 0' | grep -v grep | awk '{print $1}'") do |io|
      while true
        buffer = io.gets
        break if buffer.nil?
        pids += buffer
      end
    end
    pids.split("\n").map do |pid|
      pid.to_i
    end
  end

  private

    def wait_for_tail_process_runninng
      sleep(2)
    end

    def wait_for_tail_process_output
      sleep(2)
    end
end
