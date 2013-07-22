require 'popularity_contest'
require 'mock_redis'
require 'date'

describe PopularityContest do
  before :each do
    @redis = MockRedis.new
  end

  describe "#all_popular" do
    it "should return all popular" do
      (0..9).each do |index|
        add_event_with_id(index)
      end

      result = PopularityContest::all_popular("event", @redis)
      expect(result.size).to eq 10

      mapped_ids = result.map{|x| x[2]}
      (0..9).each do |index|
        expect(mapped_ids).to include(index)
      end
    end
  end

  describe "#most_popular" do
    it "should return 10 items by default" do
      (0..20).each do |index|
        add_event_with_id(index)
      end

      result = PopularityContest::most_popular("event", @redis)
      expect(result.size).to eq 10
    end

    it "should return limited count of items when it is passed" do
      (0..20).each do |index|
        add_event_with_id(index)
      end

      result = PopularityContest::most_popular("event", @redis, 5)
      expect(result.size).to eq 5
    end
  end

  private
    def add_event_with_id(id)
      key = PopularityContest::key("event", id)
      @redis.incr(key)
    end
end
