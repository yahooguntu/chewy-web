require 'sinatra'
require 'chewy/web/configuration'

module Chewy
  module Web
    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end
