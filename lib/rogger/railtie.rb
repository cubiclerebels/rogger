require 'rails'

module Rogger
  class Railtie < Rails::Railtie
    initializer "rogger.load-config" do
      config_file = Rails.root.join("config", "rogger.yml")
      if config_file.file?
        ::Rogger.load!(config_file)
      end
    end
  end
end