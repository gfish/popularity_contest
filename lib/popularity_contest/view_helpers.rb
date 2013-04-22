module PopularityContest
  module ViewHelpers
    def popular_count_hit_path(content_type, content_id, namespace = nil)
      begin
        build_path(content_type, content_id, namespace)
      rescue
        "<!-- error occurred in PopularityContest :| -->"
      end
    end

    def popular_count_hit_jquery(content_type, content_id, namespace = nil)
      begin
        url = build_path(content_type, content_id, namespace)
        <<-SJS
<script>
(function(window, document, $, undefined) {
  $.ajax({
    url: '#{url}',
    dataType: 'html',
    cache: false
  })
}(window, document, jQuery));
</script>
        SJS
      rescue
        "<!-- error occurred in PopularityContest :| -->"
      end
    end

    def popular_content(content_type, limit=10, namespace=nil, date=Date.today.strftime("%y-%m-%d"))
      begin
        #try to guess a redis instance
        if $redis.present?
          redis = $redis
        elsif @redis.present?
          redis = @redis
        else
          raise 'Unable to find a usable redis instance'
        end

        return PopularityContest::most_popular(content_type, redis, 10, namespace)
      rescue
        []
      end
    end

   private
    def build_path(content_type, content_id, namespace = nil)
      content_type = content_type.to_s.downcase
      uri = []
      uri << "#{Rails.application.routes.url_helpers.popularity_contest_web_path}"
      uri << "#{content_type}"
      uri << "#{content_id}"
      uri << "#{namespace}" unless namespace.nil?

      strip_locale_uri(url.join("/"))
    end
    # Because Billetto have locales in URLs like billetto.dk/da and billetto.dk/en
    # and the paths returned from Rails will include those, and this route:
    #   mount PopularityContest::Web, :at => "hit"
    # will only bind on: billetto.dk/hit/our/app
    # and not:           billetto.dk/en/hit/our/app
    def strip_locale_uri(path)
      path.to_s.gsub(/\/(en|da)/i, "")
    end
  end
end