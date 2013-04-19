require 'popularity_contest/view_helpers'

module PopularityContest
  class Railtie < Rails::Railtie
    initializer "popularity_contest.view_helpers" do |app|
      ActionView::Base.send :include, ViewHelpers
    end
  end
end