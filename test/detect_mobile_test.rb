require 'test_helper'

class MobuFake
  class << self
    def before_filter(*args) end
    def helper_method(*methods) end
  end

  def params
    {}
  end

  include Mobu::DetectMobile
end

class Rails
end

class MobuTest < MiniTest::Spec

  IPAD_USER_AGENT = "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10"
  IPHONE_USER_AGENT = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5"
  FIREFOX_USER_AGENT = "Mozilla/5.0 (Windows NT 6.2; rv:22.0) Gecko/20130405 Firefox/23.0"

  describe "controller" do
    before do
      @request = mock
      @session = MockCookies.new
      @controller = MobuFake.new
      @controller.stubs session: @session
      @controller.stubs request: @request
    end

    it "set and cache mobile_request?" do
      @controller.stubs :mobile_browser?
      @controller.stubs :tablet_request?
      refute @controller.send :mobile_request?
      @controller.stubs mobile_browser?: true # it ignore
      refute @controller.send :mobile_request?
    end

    it "detect tablet and not detect mobile for iPad user agent" do
      @request.stubs user_agent: IPAD_USER_AGENT
      assert @controller.send(:tablet_request?)
      refute @controller.send(:mobile_request?)
    end

    describe "with mobile user agent" do
      before do
        @request.stubs user_agent: IPHONE_USER_AGENT
      end

      it "prepend mobile views" do
        expect_mobile_views
        expect_no_tablet_views
        @controller.send :check_mobile_site
      end

      it "prepend mobile views with mobile preference" do
        @controller.stubs params: {prefer: "m"}
        expect_mobile_views
        expect_no_tablet_views
        @controller.send :check_mobile_site
      end

      it "not prepend mobile views with prefer_full_site cookie" do
        @session[:prefer_full_site] = 1
        expect_no_mobile_views
        expect_no_tablet_views
        @controller.send :check_mobile_site
      end
      
      it "set session cookie to prefer full site with full site preference" do
        @controller.stubs params: {prefer: "f"}
        @controller.send :check_mobile_site
        assert_equal 1, @session[:prefer_full_site]
      end      
    end

    describe "with tablet user agent" do
      before do
        @request.stubs user_agent: IPAD_USER_AGENT
      end

      it "prepend tablet views" do
        expect_tablet_views
        expect_no_mobile_views
        @controller.send :check_mobile_site
      end
    end

    describe "with browser user agent" do
      before do
        @request.stubs user_agent: FIREFOX_USER_AGENT
      end

      it "prepend no views" do
        expect_no_tablet_views
        expect_no_mobile_views
        @controller.send :check_mobile_site
      end

      it "prepend no views with prefer_full_site cookie" do
        @session[:prefer_full_site] = 1
        expect_no_tablet_views
        expect_no_mobile_views
        @controller.send :check_mobile_site
      end
    end

    describe "#prefer_full_site_url" do
      it "add prefer=f" do
        @request.stubs url: "https://neighborland.com/xyz"
        assert_equal "https://neighborland.com/xyz?prefer=f", @controller.send(:prefer_full_site_url)
      end

      it "keep existing query params" do
        @request.stubs url: "https://neighborland.com/xyz?monkeys=true&bananas=yeller"
        assert_equal "https://neighborland.com/xyz?bananas=yeller&monkeys=true&prefer=f", @controller.send(:prefer_full_site_url)
      end
    end

    describe "#prefer_mobile_site_url" do
      it "add prefer=m" do
        @request.stubs url: "https://neighborland.com/xyz"
        assert_equal "https://neighborland.com/xyz?prefer=m", @controller.send(:prefer_mobile_site_url)
      end

      it "strip existing prefer value" do
        @request.stubs url: "https://neighborland.com/xyz?prefer=f"
        assert_equal "https://neighborland.com/xyz?prefer=m", @controller.send(:prefer_mobile_site_url)
      end
    end

    describe "with fake Rails" do
      before do
        Rails.stubs root: Pathname.new("/home/snoop/yer_app/")        
      end
      
      describe "#mobile_views_path" do
        it "build path" do
          assert_equal "/home/snoop/yer_app/app/views_mobile", @controller.send(:mobile_views_path).to_s
        end
      end

      describe "#tablet_views_path" do
        it "build path" do
          assert_equal "/home/snoop/yer_app/app/views_tablet", @controller.send(:tablet_views_path).to_s
        end    
      end          
    end
  end
  
private

  def expect_mobile_views
    @controller.expects(:mobile_views_path).returns("mobile_views_path").once
    @controller.expects(:prepend_view_path).with("mobile_views_path")
  end

  def expect_tablet_views
    @controller.expects(:tablet_views_path).returns("tablet_views_path").once
    @controller.expects(:prepend_view_path).with("tablet_views_path")
  end

  def expect_no_mobile_views
    @controller.expects(:mobile_views_path).never
  end

  def expect_no_tablet_views
    @controller.expects(:tablet_views_path).never
  end
end
