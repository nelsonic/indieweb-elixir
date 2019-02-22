defmodule IndieWeb.AuthTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.Auth, as: Subject

  setup do
    Application.put_env(:indieweb, :auth_adapter, IndieWeb.Test.AuthAdapter, persistent: true)
  end

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
        refute Subject.endpoint_for(:authorization, "https://foobar.com")
      end
    end
  end

  describe ".authenticate/1" do
    @user_profile_url "https://indieauth.user/profile"
    @client_id "https://indieauth.client"
    @redirect_uri "https://indieauth.redirect/url"

    test "successfully generates a signed URI for identification" do
      params = %{
        "client_id" => @client_id,
        "me" => @user_profile_url,
        "redirect_uri" => @redirect_uri,
        "response_type" => "id",
        "state" => "state",
      }

      signed_url = Enum.join([@redirect_uri, "?", URI.encode_query(%{"state" => params["state"], "code" => IndieWeb.Test.AuthAdapter.code()})])
      assert signed_url == Subject.authenticate(params)
    end

    test "successfully generates a signed URI for generating an authorization code" do
      params = %{
        "client_id" => @client_id,
        "me" => @user_profile_url,
        "redirect_uri" => @redirect_uri,
        "response_type" => "code",
        "scope" => "read",
        "state" => "state",
      }

      signed_url = Enum.join([@redirect_uri, "?", URI.encode_query(%{"state" => params["state"], "code" => IndieWeb.Test.AuthAdapter.code()})])
      assert signed_url == Subject.authenticate(params)

    end

    test "generate an authorization code when defaulting to edfault 'read' scope" do
      params = %{
        "client_id" => @client_id,
        "me" => @user_profile_url,
        "redirect_uri" => @redirect_uri,
        "response_type" => "code",
        "state" => "state",
      }

      signed_url = Enum.join([@redirect_uri, "?", URI.encode_query(%{"state" => params["state"], "code" => IndieWeb.Test.AuthAdapter.code()})])
      assert signed_url == Subject.authenticate(params)
    end
  end
end
