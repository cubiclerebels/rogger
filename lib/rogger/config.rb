module Rogger

  require 'gelf'
  require 'yaml'
  
  module Config

    class ConfigurationObject

      include Errors
      include Utils
      attr_reader :protocol, :server_hostname, :server_port, :app_name, :disabled

      def initialize(file_location)
        begin
          @config_file = YAML.load(ERB.new(File.read(file_location)).result)
          @env_hash    = @config_file[Config.env] || @config_file['default']
          @disabled          ||= set_disabled

          # short circuit initialization if disabled:true is set for current environment
          return nil if @disabled

          @protocol          ||= set_protocol
          @server_hostname   ||= set_server_hostname
          @server_port       ||= set_server_port
          @app_name          ||= set_app_name
        rescue
        end
      end

      private

      def set_disabled
        @env_hash['disabled'] == true
      end

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
    end

    def self.env
      return Rails.env if defined?(Rails)
      return Sinatra::Base.environment.to_s if defined?(Sinatra)
      ENV["RACK_ENV"] || raise(Errors::NoEnvironment.new)
    end

    config = Config::ConfigurationObject.new('config/rogger.yml')

    if config

      @@logger = GELF::Logger.new(
        config.server_hostname, 
        config.server_port, 
        'WAN', 
        { 
          host: config.app_name,
          environment: env,
          protocol: config.protocol 
        })

      Rails.logger.extend(ActiveSupport::Logger.broadcast(@@logger))
        
    end
  end
  
end
