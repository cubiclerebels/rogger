module Rogger

  require 'gelf'
  require 'yaml'
  
  module Config

    class ConfigurationObject

      include Errors
      include Utils
      attr_reader :protocol, :server_hostname, :server_port, :app_name, :app_logging, :log_to_file

      def initialize(file_location)
        @config_file = YAML.load(ERB.new(File.read(file_location)).result)
        @env_hash    = @config_file[Config.env] || @config_file['default']
        @protocol          ||= set_protocol
        @server_hostname   ||= set_server_hostname
        @server_port       ||= set_server_port
        @app_name          ||= set_app_name
        @app_logging       ||= set_app_logging
        @log_to_file       ||= set_log_to_file
      end

      private
      def set_protocol
        case @env_hash['protocol']
          when "tcp" then GELF::Protocol::TCP
          when "udp" then GELF::Protocol::UDP
          else raise InvalidProtocolError, "Please indicate a valid protocol in rogger.yml. Valid options are 'tcp' or 'udp'"
        end
      end

      def set_server_hostname
        case @env_hash['host']
          when nil then raise InvalidHostError, "Please enter a valid server IP address or hostname in rogger.yml"
          else @env_hash['host']
        end
      end

      # TODO: Can check for valid port numbers
      def set_server_port
        case @env_hash['port']
          when Integer then @env_hash['port']
          else raise InvalidPortError, "Please enter a valid server port number in rogger.yml"
        end
      end

      def set_app_name
        case @env_hash['app_name']
          when String then @env_hash['app_name']
          else raise InvalidAppNameError, "Please enter a valid application name"
        end
      end

      def set_app_logging
        case @env_hash['app_logging']
        when Utils::is_boolean(@env_hash['app_logging']) then @env_hash['app_logging']
        else raise InvalidSettingError, "Please set to either true or false for app_logging setting"
        end
      end

      def set_log_to_file
        case @env_hash['log_to_file']
        when Utils::is_boolean(@env_hash['log_to_file']) then @env_hash['log_to_file']
        else raise InvalidSettingError, "Please set to either true or false for log_to_file setting"
        end
      end
    end

    def self.env
      return Rails.env if defined?(Rails)
      return Sinatra::Base.environment.to_s if defined?(Sinatra)
      ENV["RACK_ENV"] || raise(Errors::NoEnvironment.new)
    end

    # def self.logger
    #   @@logger
    # end

    # def self.notifier
    #   @@notifier
    # end

    # def self.file_log
    #   ActiveSupport::Logger.new("log/#{Rails.env}.log")
    # end

    def self.lograge
      Rails.application.config.logger.extend(ActiveSupport::Logger.broadcast(@@logger))
      x = Rails.application.config.lograge
      x.enabled = true
      x.formatter = Lograge::Formatters::Graylog2.new
      x.custom_options = lambda do |event|
        unwanted_keys = %w[format action controller]
        params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }
        {:params => params, :remote_ip => event.payload[:ip], :auth_token => event.payload[:auth_token], :lat => event.payload[:lat], :lng => event.payload[:lng  ], :response => event.payload[:response]}
      end
      x
    end

    config = Config::ConfigurationObject.new('config/rogger.yml')

    @@logger = GELF::Logger.new(
      config.server_hostname, 
      config.server_port, 
      'WAN', 
      { 
        host: config.app_name,
        environment: env,
        protocol: config.protocol 
      })

    @@notifier = GELF::Notifier.new(config.server_hostname, config.server_port)

    if config.app_logging
      if config.log_to_file
        Rails.logger.extend(ActiveSupport::Logger.broadcast(@@logger))
      else
        Rails.logger = @@logger
      end  
    end
  end
  
end