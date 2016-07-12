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

    # Quoted From: Rack::CommonLogger & Updated to suit Minodes::Sinatra::Logger.
    # Refer to: https://github.com/rack/rack/blob/master/lib/rack/common_logger.rb
    class AccessLogger
      FORMAT = %{%s - %s [%s] "%s %s%s %s" %d %s %0.4f\n}

      def initialize(app, logger=nil)
        @app = app
        @logger = ::SemanticLogger["Access"]
      end

      def call(env)
        began_at = Time.now
        status, header, body = @app.call(env)
        header = ::Rack::Utils::HeaderHash.new(header)
        body = ::Rack::BodyProxy.new(body) { log(env, status, header, began_at) }
        [status, header, body]
      end

      private

      def log(env, status, header, began_at)
        now = ::Time.now
        length = extract_content_length(header)

        msg = FORMAT % [
          env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
          env["REMOTE_USER"] || "-",
          now.strftime("%d/%b/%Y:%H:%M:%S %z"),
          env["REQUEST_METHOD"],
          env["PATH_INFO"],
          env["QUERY_STRING"].empty? ? "" : "?#{env["QUERY_STRING"]}",
          env["HTTP_VERSION"],
          status.to_s[0..3],
          length,
          now - began_at ]

        # This function is being called twice in the same request. Thus, it ends up printing output twice.
        # Refer to: http://stackoverflow.com/questions/31206060/sinatra-with-puma-gives-twice-the-output-in-the-terminal
        @logger.info(msg)
      end

      def extract_content_length(headers)
        value = headers["Content-Length"] or return '-'
        value.to_s == '0' ? '-' : value
      end
    end

    module Logger
      class << self
        attr_accessor :configuration
        attr_accessor :written
      end

      def self.configure
        self.configuration ||= Configuration.new
        yield(self.configuration)

        if configuration.file_name.nil?
          raise "Minodes::Sinatra::Logger -- File name is not specified. Please, set `file_name` in the configuration block!"
        end

        ::SemanticLogger.default_level = configuration.log_level
        ::SemanticLogger.add_appender(file_name: configuration.file_name, formatter: :color)

        ::Sinatra::Base.class_eval do
          before do
            env["rack.errors"] = Minodes::Sinatra::ErrorLogger.new
            env["rack.logger"] = ::SemanticLogger[self.class.name]
          end

          configure do
            set :logging, nil
            use Minodes::Sinatra::AccessLogger
          end
        end
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
