module Rogger

  def self.log_exceptions!
    begin
      yield if block_given?
    rescue Exception => e
      @@logger.error e
      raise e
    end
  end

  def self.log_exceptions
    begin
      yield if block_given?
    rescue Exception => e
      @@logger.error e
    end
  end

  require 'gelf'
  ::GELF::Levels.constants.each do |const|
    module_eval <<-EOT, __FILE__, __LINE__ + 1
      def self.#{const.downcase}(msg = "", &block)
        @@logger.#{const.downcase}(msg, &block)
      end
    EOT
  end

end