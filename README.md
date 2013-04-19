# PopularityContest

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'popularity_contest'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install popularity_contest

## Usage

Add this rack application to your Rails routes:

```ruby
require 'popularity_contest/web'
mount PopularityContest::Web, :at => "popularity"
```

You can now reach it from `HOSTNAME/popularity`.

To use in your views you have a helper here:

```ruby
<%= count_hit_path('event', 1337) %>
# /popularity/event/1337
```

Or if you have jQuery available you can use this:

```ruby
<%= count_hit_jquery('event', 1337) %>
# <script>
# (function(window, document, $, undefined) {
#  $.ajax({
#    url: '/popularity/event/1337',
#    dataType: 'html',
#    cache: false
#  })
# }(window, document, jQuery));
# </script>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
