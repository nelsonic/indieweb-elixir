defmodule IndieWeb.AuthTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.Auth, as: Subject

  describe ".endpoint_for/2" do
    @endpoint "https://jacky.wtf/endpoint"

    test "authorization endpoint - successfully finds" do
      html = "<html><head><link rel='authorization_endpoint' href='#{@endpoint}' /></head></html>"
      use_cassette :stub, uri: "~r/*/", body: html do
        assert @endpoint = Subject.endpoint_for(:authorization, "https://foobar.com")
      end
    end

    test "authorization endpoint - finds none for site" do
      html = "<html><head></head></html>"
      use_cassette :stub, uri: "~r/*/", body: html do
        refute Subject.endpoint_for(:authorization, "https://foobar.com")
      end
    end

    test "token endpoint - successfully finds" do
      html = "<html><head><link rel='token_endpoint' href='#{@endpoint}' /></head></html>"
      use_cassette :stub, uri: "~r/*/", body: html do
        assert @endpoint = Subject.endpoint_for(:token, "https://foobar.com")
      end
    end

    test "token endpoint - finds none for site" do
      html = "<html><head></head></html>"
      use_cassette :stub, uri: "~r/*/", body: html do
        refute Subject.endpoint_for(:token, "https://foobar.com")
      end
    end
  end
end
