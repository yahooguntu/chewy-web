module Chewy::Web
  class Configuration
    attr_accessor :redis, :queue, :max_history

    def initialize
      @queue = :chewy_web
      @max_history = 20
    end
  end
end
