module Rogger

  require 'gelf'
  require 'yaml'

  module Config
    def self.env_name
      return Rails.env if defined?(Rails)
      return Sinatra::Base.environment.to_s if defined?(Sinatra)
      ENV["RACK_ENV"] || ENV["MONGOID_ENV"] || raise(Errors::NoEnvironment.new)
    end
  end

  environment = Rogger::Config.env_name

  config_file = YAML.load_file('config/rogger.yml')

  @@logger = GELF::Logger.new(
    config_file['config']['graylog_server'], 
    config_file['config']['graylog_server_port'], "WAN", 
    { :host => config_file['config']['app_name'], 
      :environment =>  environment })

end