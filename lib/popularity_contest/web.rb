require 'sinatra'
require "sinatra/reloader"
require "sinatra/json"

module PopularityContest
  class Web < Sinatra::Base
    helpers Sinatra::JSON

    class BadRequest < StandardError; end

    configure :development do
      register Sinatra::Reloader # reload code when we develop

      # For easier local development (act as production):
      # set :raise_errors, false
      # set :show_exceptions, false
      # set :dump_errors, false
    end

    def initialize(app = nil)
      super
      @app = app
      redis_config = YAML.load_file(File.join(Rails.root, "/config/resque.yml"))
      redis_url = redis_config[Rails.env]
      redis_url = "http://#{redis_url}"
      uri = URI.parse(redis_url)

      begin
        @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
        puts "=> Statistics Redis connection success"
      rescue => e
        puts "=> Statistics Redis connection failure"
        puts e.backtrace
      end
    end

    get '/pretty/:type' do
      keys = @redis.keys(PopularityContest::key(params[:type], '*'))

      hits = @redis.pipelined do
        keys.each do |key|
          @redis.mget(key)
        end
      end.flatten.collect{|hit| hit.to_i }
      # each of these hits is an array, flatten that
      # and convert the hits to integer
      # unfortunately Redis doesn't support the integer datatype as default

      # get all the content_ids
      content_ids = keys.collect{|key| PopularityContest::content_id_from_key(key) }

      # merge the three arrays: [keys, hits, content_ids]
      # [ "popular:type:event:id:66:date:13-04-18:count",
      #   "2",
      #   1337 ]
      # and sort them highest to lowest
      content_hits = [keys, hits, content_ids].transpose.sort! { |x,y| y[1].to_i <=> x[1].to_i }
      content_hits.to_json
    end

    get '/:type/:id' do
      content_id = params[:id].to_i
      if(content_id != 0) # check if ID is present as an integer
        content_type :json
        {:content => "#{params[:type]}##{content_id}"}.to_json
        incr_key(params[:type], content_id)
      else
        raise BadRequest, "invalid input format"
      end
    end

    get '/test' do
      100.times do |event_id|
        Random.rand(1...1000).times do |hits|
          incr_key('event', event_id)
        end
      end
    end

   private
    # Redis-helpers
    def incr_key(content_type, content_id)
      @redis.multi do
        key = PopularityContest::key(content_type, content_id)
        @redis.incr(key)
        @redis.expire(key, 48*60*60) # each time we increment we expire 48 hours out in the future
      end
    end

    # Error-handling
    def error(statuscode, message)
      content_type :json
      status statuscode.to_i # or whatever

      logger.info "#{statuscode} - #{message}"

      {:error => message}.to_json
    end
    error BadRequest do
      e = env['sinatra.error']
      error(500, e.message)
    end
  end
end