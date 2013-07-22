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
      puts "PopularityContest: Running in #{Sinatra::Base.environment} environment"
      begin
        @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
        #puts "=> Statistics Redis connection success"
      rescue => e
        puts "=> Statistics Redis connection failure"
        puts e.backtrace
      end
    end

    # For testing what is in the DB
    # get '/pretty/:type' do
    #   PopularityContest::most_popular(params[:type], @redis, 10).to_json
    # end

    # For testing populating the keys
    # get '/test' do
    #   100.times do |event_id|
    #     Random.rand(1...1000).times do |hits|
    #       incr_key('event', event_id)
    #     end
    #   end
    # end

    # For incrementing a key:
    get '/:type/:id' do
      content_id = params[:id].to_i
      if(content_id != 0) # check if ID is present as an integer
        content_type :json
        incr_key(params[:type], content_id)
        {:content => "#{params[:type]}##{content_id}", :key => PopularityContest::key(params[:type], content_id)}.to_json
      else
        raise BadRequest, "invalid input format"
      end
    end

   private
    # Redis-helpers
    def incr_key(content_type, content_id)
      @redis.multi do
        key = PopularityContest::key(content_type, content_id)
        puts "PopularityContest: Incrementing key='#{key}'" if Sinatra::Base.development?
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
