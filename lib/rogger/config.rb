module Rogger

  require 'gelf'
  require 'yaml'

  module Config

    def self.env_name
      return Rails.env if defined?(Rails)
      return Sinatra::Base.environment.to_s if defined?(Sinatra)
      ENV["RACK_ENV"] || ENV["MONGOID_ENV"] || raise(Errors::NoEnvironment.new)
    end
    def self.logger
      @@logger
    end

    def self.notifier
      @@notifier
    end

    def self.file_log
      ActiveSupport::Logger.new("log/#{Rails.env}.log")
    end

    env_log = ActiveSupport::Logger.new("log/#{Rails.env}.log")
    Rails.logger.extend ActiveSupport::Logger.broadcast(env_log)

    environment = Rogger::Config.env_name

    config_file = YAML.load(ERB.new(File.read("#{Rails.root}/config/rogger.yml")).result)
    app_name = config_file['config'].try(:[], "#{Rails.env}").try(:[], 'app_name') || config_file['config']['app_name']

    @@logger = GELF::Logger.new(
      config_file['config']['graylog_server'], 
      config_file['config']['graylog_server_port'], "WAN",
      { :host => app_name,
        :environment =>  environment })

    if config_file['config']['log_to_file']
      Rails.logger.extend(ActiveSupport::Logger.broadcast(@@logger)) unless !config_file['config']['app_logging']
    else
      Rails.logger = @@logger unless !config_file['config']['app_logging']
    end

    @@notifier = GELF::Notifier.new(config_file['config']['graylog_server'], config_file['config']['graylog_server_port'])

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

  end
end
