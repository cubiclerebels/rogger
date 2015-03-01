module Rogger
  module Generators

    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      # def create_initializer_file
      #   copy_file 'rogger.rb', 'config/initializers/rogger.rb'
      # end

      def create_config_file
        copy_file 'rogger.yml', 'config/rogger.yml'
        copy_file 'rogger.rb', 'config/initializers/rogger.rb'
      end
    end

  end
end
