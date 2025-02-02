# frozen_string_literal: true

require 'ustruct'
require_relative "tiny_cloud/version"
require_relative "tiny_cloud/storage"
require_relative "tiny_cloud/time_calculation"
require_relative "tiny_cloud/request_processor"
require_relative "tiny_cloud/request"
require_relative "tiny_cloud/hook"
require_relative "tiny_cloud/action_hook"
require_relative "tiny_cloud/excon/http_client"

module TinyCloud
  class Error < StandardError; end
  # Your code goes here...
end
