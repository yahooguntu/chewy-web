module Chewy::Web
  module Workers
    class Base
      include Sidekiq::Worker

      @@redis = nil

      def self.redis
        return @@redis if @@redis

        redis_opts = Chewy::Web.configuration.redis
        return @@redis = Redis.new(redis_opts) if redis_opts
        return @@redis = Redis.new
      end

      def self.locked?(index_name)
        redis.get(self.redis_key(index_name))
      end

      private

      def self.lock(index_name, action=true)
        redis.set(self.redis_key(index_name), action)
      end

      def self.unlock(index_name)
        redis.del(self.redis_key(index_name))
      end

      def self.redis_key(index_name)
        "chewy:web:#{index_name}"
      end

      # returns job history, or single history record if date is provided
      def self.get_history(name, date=nil)
        range = (date ? [date.to_i, date.to_i, limit: [0,1]] : ['-inf', 'inf'])
        histories = redis.zrangebyscore(history_key(name), *range).map do |item|
          JSON.parse(item) || []
        end
        date ? histories.first : histories
      end

      # adds/overwrites job history for date in hash[:start_time]
      def self.set_history(name, hash)
        start = hash['start_time'] || hash[:start_time]
        redis.zremrangebyscore(history_key(name), start.to_i, start.to_i)
        redis.zadd(history_key(name), start.to_i, hash.to_json)
        trim_history(name)
      end

      def self.log_start(name:, action:, time:, jid:)
        set_history(name, {
          jid: jid,
          start_time: time,
          action: action
        })
      end

      def self.log_finish(name:, result:, time:)
        history = get_history(name, time)
        history[:end_time] = Time.now.to_i
        history[:result] = result
        set_history(name, history)
      end

      # keep top 5 entries
      def self.trim_history(name)
        redis.zremrangebyrank(history_key(name), 0, (Chewy::Web.configuration.max_history + 1) * -1)
      end

      def self.history_key(name)
        redis_key(name) + ":history"
      end

    end
  end
end

