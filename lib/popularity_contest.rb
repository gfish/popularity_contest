module PopularityContest
  NAME = "PopularityContest"
  LICENSE = 'See LICENSE for licensing details.'

 private
  # helpers
  def self.key(content_type, content_id, date = Date.today.strftime("%y-%m-%d"))
    "popular:type:#{content_type}:id:#{content_id}:date:#{date}:hits"
  end

  def self.content_id_from_key(key)
    # 'popular:type:#{content_type}:id:12456:date:#{Date.today.strftime("%y-%m-%d")}:count'.scan(/id:(\d+)/i).flatten.first
    key.scan(/id:(\d+)/i).flatten.first.to_i
  end
end

require 'popularity_contest/railtie' if defined?(::Rails::Engine)