require 'database_stalker/util'

module ProcessHelper

  def kill_all_tail_process
    DatabaseStalker::Util.runned_tail_pids.each do |pid|
      Process.kill('KILL', pid)
    end
  end
end
