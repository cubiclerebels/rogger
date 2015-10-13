module Rogger
  module Errors

    class RoggerError < StandardError
    end

    class NoEnvironment < RoggerError
    end

    class InvalidProtocolError < RoggerError
    end

    class InvalidIpError < RoggerError
    end

    class InvalidPortError < RoggerError
    end

  end
end