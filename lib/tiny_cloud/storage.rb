# frozen_string_literal: true

module TinyCloud
  # storage class
  class Storage
    attr_accessor :account, :url, :type

    def initialize(account, url:, type: :storage)
      @account = account
      @url = TinyUrl.new(url)
      @type = type
      yield account.configuration if block_given?
    end

    def call(sub_storage_name)
      return unless type == :storage #  a single nested storage level (container)

      container = self.class.new(
        account,
        url: TinyUrl.add_to_path(url, sub_storage_name),
        type: :container
      )
      yield container if block_given?
      container
    end

    # delegation to account : building operation queues to be performed
    def method_missing(action, **options)
      account.call(
        action,
        Ustruct.new(options, url: url, type: type)
      )
    end

    def respond_to_missing?(action, **_options)
      account.respond_to_action? action
    end

    private

    def join_paths(*paths)
      paths.compact.join('/')
    end
  end
end
