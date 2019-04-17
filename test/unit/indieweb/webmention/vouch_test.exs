defmodule IndieWeb.Webmention.VouchTest do
  use IndieWeb.TestCase, async: false
  use IndieWeb.HttpMock
  alias IndieWeb.Webmention.Vouch, as: Subject

  describe ".valid?/2" do
    test "confirms remote h-card exists on vouch page" do
      use_cassette "webmention_vouch_indieweb_chatnames" do
        assert Subject.valid?(
                 "https://indieweb.org/chat-names",
                 "https://jacky.wtf"
               )
      end
    end
  end
end
