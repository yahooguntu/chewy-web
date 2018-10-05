require 'sinatra'
require 'chewy/web/index_status'
require 'chewy/web/render_utils'
require 'chewy/web/index_utils'
require 'chewy/web/workers/index_worker'

module Chewy::Web
  class Server < Sinatra::Base
    helpers RenderUtils

    before do
      begin
        @health = Chewy.client.cluster.health['status']
      rescue
        @health = 'red'
      end
      @index_classes = IndexUtils.index_classes
    end

    get '/' do
      @status = IndexStatus.new
      erb :index
    end

    delete '/:index' do
      if Chewy.client.indices.delete index: params['index']
        @success = "Index #{params['index']} was deleted"
      else
        @error = "Can't delete index #{params['index']}"
      end
      erb :message
    end

    put '/:index/reset' do
      if IndexUtils.index_class_names.include? params['index']
        Workers::IndexWorker.perform_async(params['index'], 'reset', params[:parallel])
        @success = "Reset started on #{params['index']}"
      else
        @error = "No such index!"
      end
      erb :message
    end

    put '/:index/sync' do
      if IndexUtils.index_class_names.include? params['index']
        Workers::IndexWorker.perform_async(params['index'], 'sync', params[:parallel])
        @success = "Sync started on #{params['index']}"
      else
        @error = "No such index!"
      end
      erb :message
    end

  end
end
