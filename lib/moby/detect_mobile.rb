require 'active_support/concern'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'rack/utils'
require 'uri'

module Moby
  module DetectMobile
    extend ActiveSupport::Concern

    # List of mobile agents from mobile_fu:
    # https://github.com/brendanlim/mobile-fu/blob/master/lib/mobile_fu.rb
    MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                         'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                         'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                         'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                         'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'

    TABLET_USER_AGENTS = 'ipad|android 3.0|xoom|sch-i800|playbook|tablet|kindle|honeycomb|gt-p1000'

    included do
      before_filter :check_mobile_site

      helper_method :mobile_request?,
                    :mobile_browser?,
                    :prefer_full_site_url,
                    :prefer_mobile_site_url,
                    :tablet_request?,
                    :tablet_browser?
    end

  private

    def mobile_views_path
      @@mobile_views_path ||= Rails.root + 'app' + 'views_mobile'
    end

    def tablet_views_path
      @@tablet_views_path ||= Rails.root + 'app' + 'views_tablet'
    end

    def prefer_full_site_url
      _view_url "f"
    end

    def prefer_mobile_site_url
      _view_url "m"
    end

    # preference: m, f (mobile, full)
    def _view_url(preference)
      uri = URI(request.url)
      query = Rack::Utils.parse_nested_query(uri.query)
      query["prefer"] = preference
      uri.query = query.to_param
      uri.to_s
    end

    def force_full_site
      session[:prefer_full_site]
    end

    def mobile_request?
      if defined?(@mobile_request)
        @mobile_request
      else
        @mobile_request = !force_full_site && !tablet_request? && mobile_browser?
      end
    end

    def mobile_browser?
      user_agent_matches(MOBILE_USER_AGENTS)
    end

    def tablet_request?
      if defined?(@tablet_request)
        @tablet_request
      else
        @tablet_request = tablet_browser?
      end
    end

    def tablet_browser?
      user_agent_matches(TABLET_USER_AGENTS)
    end

    def check_mobile_site
      case params.delete(:prefer)
      when "f"
        session[:prefer_full_site] = 1
      when "m"
        session.delete :prefer_full_site
      end

      if mobile_request?
        prepend_view_path mobile_views_path
      elsif tablet_request?
        prepend_view_path tablet_views_path
      end
    end

    def user_agent_matches(regex)
      !!( request.user_agent.to_s.downcase =~ /(#{regex})/ )
    end

  end
end
