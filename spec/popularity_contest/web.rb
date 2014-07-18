require 'rack/test'

require File.expand_path '../../../lib/popularity_contest/web.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() ::PopularityContest::Web end
end

RSpec.configure { |c| c.include RSpecMixin }

describe PopularityContest::Web do
  it "handles cors options query" do
    options '/event/123'
    expect(last_response).to be_ok
    expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
    expect(last_response.headers['Access-Control-Allow-Methods']).to eq('GET, OPTIONS')
    expect(last_response.headers['Access-Control-Allow-Headers']).to eq('Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token')
  end
end

