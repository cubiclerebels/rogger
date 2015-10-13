module Rogger
  module Errors

    class RoggerError < StandardError
    end

    class NoEnvironment < RoggerError
    end

    class InvalidProtocolError < RoggerError
    end

    class InvalidHostError < RoggerError
    end

    class InvalidPortError < RoggerError
    end

    class InvalidAppNameError < RoggerError
    end

    class InvalidSettingError < RoggerError
    end

  end
end