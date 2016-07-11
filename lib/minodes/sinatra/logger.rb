require "minodes/sinatra/logger/version"
require "sinatra"
require "semantic_logger"

module Minodes
  module Sinatra
    class ErrorLogger
      def puts(msg)
        SemanticLogger["Error"].error msg
      end
    end

    module Logger
      class << self
        attr_accessor :configuration
      end

      def self.configure
        self.configuration ||= Configuration.new
        yield(configuration)

        if configuration.file_name.nil?
          raise "Minodes::Sinatra::Logger -- File name is not specified. Please, set `file_name` in the configuration block!"
        end

        SemanticLogger.default_level = configuration.log_level
        SemanticLogger.add_appender(file_name: configuration.file_name, formatter: :color)

        ::Sinatra::Application.before do
          puts "++ BEFORE ALL"
          env["rack.errors"] = Minodes::Sinatra::ErrorLogger.new
          env["rack.logger"] = ::SemanticLogger[self.class.name]
        end

        ::Sinatra::Application.use ::Rack::CommonLogger, ::SemanticLogger["Access"]
      end

      class Configuration
        attr_accessor :log_level
        attr_accessor :file_name

        def initialize
          @log_level = :warn
          @file_name = nil
        end
      end
    end
  end
end
