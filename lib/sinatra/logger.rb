require "sinatra/logger/version"
require "sinatra"
require "rack"
require 'rack/body_proxy'
require 'rack/utils'
require "semantic_logger"
require "logger"

module Sinatra
  class ErrorLogger
    def puts(msg)
      SemanticLogger["Error"].error msg
    end

    def flush
      SemanticLogger.flush
    end

    def <<(msg)
      # To satisfy test calls. This function is available on "Logger" class by default.
    end
  end

  module Logger
    ::Sinatra::Base.class_eval do
      def self.logger(config)
        config[:level] ||= :trace
        ::SemanticLogger.default_level = config[:level]

        config[:formatter] ||= :color

        set :logging, true
        use ::Rack::CommonLogger, ::SemanticLogger[config[:name] || self.class.name]

        if defined?(::ActiveRecord::Base)
          # ActiveRecord Logger
          ::ActiveRecord::Base.logger = ::SemanticLogger["SQL"]
        end

        ::Sinatra::Base.before do
          ::SemanticLogger.default_level = config[:level]
          ::SemanticLogger.appenders.each { |a| ::SemanticLogger.remove_appender(a) }
          case config[:appender].to_sym
          when :file
            if config[:filename].nil?
              raise "Sinatra::Logger -- File name is not specified. Please, set `filename` in the configuration block!"
            end
          when :stdout
            ::SemanticLogger.add_appender(
              io: $stdout,
              formatter: config[:formatter],
            )
          when :syslog
            if config[:syslog_url].nil?
              ::SemanticLogger.add_appender(
                appender: :syslog,
                formatter: config[:formatter]
              )
            else
              ::SemanticLogger.add_appender(
                appender: :syslog,
                url: config[:syslog_url],
                formatter: config[:formatter],
              )
            end
          end

          env["rack.errors"] = ::Sinatra::ErrorLogger.new
          env["rack.logger"] = ::SemanticLogger[config[:name] || self.class.name]
        end
      end
    end
  end
end
