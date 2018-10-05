require 'sidekiq/api'
require 'chewy/web/index_utils'
require 'chewy/web/workers/index_worker'

if defined?(Rails)
  # Load all indices in dev mode if eager loading is turned off
  Dir["./app/chewy/*"].each { |f| require f } if Rails.env.development? && !Rails.application.config.eager_load
end

module Chewy::Web
  class IndexStatus

    # returns { [index_name] => [is_active?] }
    def indices(klass)
      @_phys_indices ||= Chewy.client.indices.get_aliases
        .reduce({}) do |h,pair|
          next h unless c_ind = IndexUtils.index_classes.find { |i| pair.first.starts_with? i.index_name }
          (h[c_ind.name] ||= {})[pair.first] = pair.last['aliases'].keys.include?(c_ind.index_name)
          h
        end
      @_phys_indices[klass.try(:name)] || {}
    end

    def status(name)
      fetch_stats.dig(name, 'status')
    end

    def document_count(name)
      fetch_stats.dig(name, 'docs.count')
    end

    def locked?(klass)
      Workers::IndexWorker.locked?(klass.to_s)
    end

    def spec_changed?(klass)
      klass.specification.changed?
    end

    def history(klass)
      hist = Workers::IndexWorker.history(klass.to_s)
      hist = hist.sort_by { |h| h['start_time'] }.reverse

      # check if most recent job, if unfinished, is still running
      first = hist.first

      # skip if job doesn't exist, has a result, or was started within the past three seconds
      if first.present? && !first.has_key?('result')
        if Time.now.to_i - first['start_time'] < 3
          first['result'] = 'Pending'
        else
          Sidekiq::Workers.new.each do |_,_,work|
            if work.dig('payload', 'jid') == first['jid']
              first['result'] = 'Running'
              break
            end
          end
        end
      end

      hist
    end

    # returns string
    def size(name)
      fetch_stats.dig(name, 'pri.store.size')
    end

    private

    def fetch_stats
      indices(nil) # trigger load
      @_stats ||= Chewy.client.cat
        .indices(index: @_phys_indices.values.map(&:keys).flatten.join(','), format: 'json')
        .reduce({}) { |h,i| h[i.delete('index')] = i; h }
    end

  end
end
