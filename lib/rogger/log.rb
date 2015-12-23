module Rogger

  def self.with_logging
    begin
      yield if block_given?
    rescue Exception => e
      @@logger.error e
    end
  end
end