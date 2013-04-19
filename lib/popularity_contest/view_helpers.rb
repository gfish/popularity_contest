  # Rails.application.routes.url_helpers.new_post_path
  # => '/posts/new'

  # Rails.application.routes.url_helpers.edit_person_url(@person, :host => 'server.com')
  # => 'http://server.com/people/3/edit'

module PopularityContest
  module ViewHelpers
    def count_hit_path(content_type, content_id)
      begin
        build_path(content_type, content_id)
      rescue
        "<!-- error occurred in PopularityContest :| -->"
      end
    end

    def count_hit_jquery(content_type, content_id)
      begin
        url = build_path(content_type, content_id)
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

    def most_viewed(content_type, limit=10, date = Date.today.strftime("%y-%m-%d"))

    end

   private
    def build_path(content_type, content_id)
      content_type = content_type.to_s.downcase
      strip_locale_uri("#{Rails.application.routes.url_helpers.popularity_contest_web_path}/#{content_type}/#{content_id}")
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