module Rogger
  module Errors

    class RoggerError < StandardError
      def compose_message(key, attributes)
        key + attributes.to_s
      end
    end


    class NoEnvironment
      def initialize
        super(compose_message("no_environment"), {})
      end
    end

    
  end
end