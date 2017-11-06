$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "database_stalker"
require "support/file_helper"

RSpec.configure do |config|
  config.include FileHelper
end
