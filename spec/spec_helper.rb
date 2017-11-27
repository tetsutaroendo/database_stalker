$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "database_stalker"
require "support/file_helper"
require "support/process_helper"

RSpec.configure do |config|
  config.include FileHelper
  config.include ProcessHelper
end
