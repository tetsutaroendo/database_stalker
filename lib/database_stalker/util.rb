module DatabaseStalker::Util

  module_function

  def runned_tail_pids
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
end
