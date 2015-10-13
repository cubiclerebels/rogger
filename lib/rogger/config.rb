module Rogger

  require 'gelf'
  require 'yaml'
  include Errors

  module Config
    def self.env_name
      return Rails.env if defined?(Rails)
      return Sinatra::Base.environment.to_s if defined?(Sinatra)
      ENV["RACK_ENV"] || raise(Errors::NoEnvironment.new)
    end

    class ConfigurationObject

      attr_reader :protocol, :protocol, :server_ip, :server_port, :app_name, :app_logging, :log_to_file

      def initialize(file_location)
        @config_file = YAML.load_file(file_location)
        @protocol    ||= set_protocol
        @server_ip   ||= set_server_ip
        @server_port ||= set_server_port
        @app_name    ||= set_app_name
        @app_logging ||= set_app_logging
        @log_to_file ||= set_log_to_file
      end

      private
      def set_protocol
        case @config_file['config']['protocol']
          when "tcp" then GELF::Protocol::TCP
          when "udp" then GELF::Protocol::UDP
          else raise Errors::InvalidProtocolError, "Please indicate a valid protocol in rogger.yml. Valid options are 'tcp' or 'udp'"
        end
      end

      # TODO: Can check for valid IPs here?
      def set_server_ip
        case @config_file['config']['graylog_server']
          when nil then raise InvalidIpError, "Please enter a valid server IP in rogger.yml"
          else @config_file['config']['graylog_server']
        end
      end

      # TODO: Can check for valid port numbers
      def set_server_port
        case @config_file['config']['graylog_server_port']
          when Integer then @config_file['config']['graylog_server_port']
          else raise InvalidPortError, "Please enter a valid server port number in rogger.yml"
        end
      end

      def set_app_name
        @config_file['config']['app_name']
      end

      def set_app_logging
        @config_file['config']['app_logging']
      end

      def set_log_to_file
        @config_file['config']['log_to_file']
      end
    end
  end

  config = Config::ConfigurationObject.new('config/rogger.yml')


  @@logger = GELF::Logger.new(
    config.server_ip, 
    config.server_port, 'WAN', 
    { host: config.app_name,
      environment: Rogger::Config.env_name,
      protocol: config.protocol })

  if config.app_logging
    if config.log_to_file
      Rails.logger.extend(ActiveSupport::Logger.broadcast(@@logger))
    else
      Rails.logger = @@logger
    end  
  end
  
end