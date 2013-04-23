module PopularityContest
  NAME = "PopularityContest"
  LICENSE = 'See LICENSE for licensing details.'

 private
  # helpers
  def self.key(content_type, content_id, date = Date.today.strftime("%y-%m-%d"))
    key = []
    key << "popular"
    key << "type:#{content_type}"
    key << "id:#{content_id}"
    key << "date:#{date}"
    key << "hits"
    key.join(":")
  end

  def self.content_id_from_key(key)
    # 'popular:type:#{content_type}:id:12456:date:#{Date.today.strftime("%y-%m-%d")}:count'.scan(/id:(\d+)/i).flatten.first
    key.scan(/id:(\d+)/i).flatten.first.to_i
  end

  def self.most_popular(content_type, redis_connection, limit=10, date=Date.today.strftime("%y-%m-%d"))
      limit = 10 if limit.nil? || !limit.is_a?(Integer) # make sure limit is right, else default
      keys = redis_connection.keys(PopularityContest::key(content_type, '*'))

      hits = redis_connection.pipelined do
        keys.each do |key|
          redis_connection.mget(key)
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
      [keys, hits, content_ids].transpose.sort! { |x,y| y[1].to_i <=> x[1].to_i }.take(limit)
  end
end

require 'popularity_contest/railtie' if defined?(::Rails::Engine)