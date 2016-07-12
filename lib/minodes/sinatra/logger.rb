require "minodes/sinatra/logger/version"
require "sinatra"
require "rack"
require 'rack/body_proxy'
require 'rack/utils'
require "semantic_logger"
require "logger"

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
        attr_accessor :appenders_assigned
      end

      def self.configure
        self.configuration ||= Configuration.new
        yield(self.configuration)

        if configuration.file_name.nil?
          raise "Minodes::Sinatra::Logger -- File name is not specified. Please, set `file_name` in the configuration block!"
        end

        if configuration.app.nil?
          raise "Minodes::Sinatra::Logger -- App is not specified. Please, set `app` in the configuration block!"
        end

        ::Sinatra::Base.class_eval do
          before do
            unless Minodes::Sinatra::Logger.appenders_assigned      # Assign appenders only once in the request lifetime
              Minodes::Sinatra::Logger.appenders_assigned = true    # There will be as many requests as there're applications in the middleware stack.
                                                                    # For example, if you create multiple Sinatra::Application (and use then inside each other, this use case will pop up)

              env["rack.errors"] = Minodes::Sinatra::ErrorLogger.new
              env["rack.logger"] = ::SemanticLogger[self.class.name]

              # Re-assign the appenders (on every request)
              ::SemanticLogger.default_level = configuration.log_level
              ::SemanticLogger.appenders.each { |a| ::SemanticLogger.remove_appender(a) }
              ::SemanticLogger.add_appender(file_name: configuration.file_name, formatter: :color)
            end
          end
        end

        # It's enough to assign the common logger to the parent app! (even if there're multiple modular/nested apps included)
        configuration.app.configure do
          set :logging, true
          use ::Rack::CommonLogger, ::SemanticLogger["Access"]
        end
      end

      class Configuration
        attr_accessor :log_level
        attr_accessor :file_name
        attr_accessor :app

        def initialize
          @log_level = :warn
          @file_name = nil
          @app = nil
        end
      end
    end
  end
end
