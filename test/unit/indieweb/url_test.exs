defmodule IndieWeb.URLTest do
  use IndieWeb.TestCase, async: false
  use IndieWeb.HttpMock
  alias IndieWeb.URL, as: Subject

  doctest Subject

  describe ".resolve_redirect/1" do
    test "resolves HTTP to HTTPS" do
      assert "https://example.com" =
               Subject.resolve_redirect("http://jacky.wtf")
    end

    test "resolves 'www'. to '' prefixing"
    test "resolves to a different path"
    test "resolves to a different domain"
  end

  describe ".canonalize/1" do
    test "returns full URL unchanged" do
      url = URI.parse("https://example.com/")
      assert ^url = Subject.canonalize(url)
    end

    test "adds a trailing '/' to URL without a path" do
      url = URI.parse("https://example.com")
      assert Subject.canonalize(url) == URI.parse("https://example.com/")
    end
  end
end
