require 'minitest/autorun'
require 'popularity_contest'
require 'mock_redis'
require 'date'

class PopularityContestTest < MiniTest::Test
  def setup
    @redis = MockRedis.new
  end

  def test_all_popular_return_all_popular
    (0..9).each do |index|
      add_event_with_id(index)
    end

    result = PopularityContest::all_popular("event", @redis)
    assert_equal 10, result.size

    mapped_ids = result.map{|x| x[2]}
    (0..9).each do |index|
      assert_includes mapped_ids, index
    end
  end

  def test_most_popular_return_10_by_default
    (0..20).each do |index|
      add_event_with_id(index)
    end

    result = PopularityContest::most_popular("event", @redis)
    assert_equal 10, result.size
  end

  def test_most_popular_return_limited_data
    (0..20).each do |index|
      add_event_with_id(index)
    end

    result = PopularityContest::most_popular("event", @redis, 5)
    assert_equal 5, result.size
  end

  private
    def add_event_with_id(id)
      key = PopularityContest::key("event", id)
      @redis.incr(key)
    end
end
