require 'chewy/web/workers/base'

module Chewy::Web
  module Workers
    class IndexWorker < Base
      sidekiq_options queue: Chewy::Web.configuration.queue, retry: false

      def perform(index_klass, action, parallel=false)
        warn("Cannot perform #{action} on #{index_klass}; another operation is already underway") and return if self.class.locked?(index_klass)
        debug("Starting #{action}#{parallel ? '(p)' : ''} on #{index_klass}...")
        index = index_klass.constantize

        self.class.lock(index_klass, "#{action}#{parallel ? '(p)' : ''}")
        start_time_key = Time.now.to_i
        self.class.log_start(name: index_klass, action: "#{action}#{parallel ? '(p)' : ''}", time: start_time_key, jid: self.jid)

        case action
        when 'reset'
          index.reset!((Time.now.to_f * 1000).round, parallel: parallel) # math matches what rake helper does
          @result = "Success"
        when 'sync'
          Chewy.derive_types(index).each do |index_type|
            results = index_type.sync(parallel: parallel)
            @result = "Success; missing: #{results[:missing].count}, outdated: #{results[:outdated].count}, total: #{results[:count]}"
            debug(@result)
          end
        else
          @result = "Invalid action '#{action}'!"
          warn(@result)
        end

        self.class.log_finish(name: index_klass, result: @result, time: start_time_key)

      rescue StandardError => e
        # NewRelic::Agent.notice_error(e)
        warn("Exception occurred: #{e}\n" + e.backtrace.join("\n"))
        self.class.log_finish(name: index_klass, result: "Error: #{e.class}: #{e.message}", time: start_time_key)
      ensure
        self.class.unlock(index_klass)
      end

      def self.history(name)
        self.get_history(name)
      end

      private

      def warn(str)
        Rails.logger.warn('[ChewyReindexWorker] ' + str)
      end

      def debug(str)
        Rails.logger.warn('[ChewyReindexWorker] ' + str)
      end

    end
  end
end
