defmodule IndieWeb.AuthTest do
  use IndieWeb.TestCase, async: true
  use IndieWeb.HttpMock
  alias IndieWeb.Auth, as: Subject

  describe ".endpoint_for/2" do
    @endpoint "https://jacky.wtf/endpoint"

    test "authorization endpoint - successfully finds" do
      html =
        "<html><head><link rel='authorization_endpoint' href='#{@endpoint}' /></head></html>"

      use_cassette :stub, uri: "~r/*/", body: html do
        assert @endpoint =
                 Subject.endpoint_for(:authorization, "https://foobar.com")
      end

      no_html = "<html></html>"

      use_cassette :stub,
        uri: "~r/*/",
        body: no_html,
        headers: %{"Link" => "<#{@endpoint}>; rel=\"authorization_endpoint\""} do
        assert @endpoint =
                 Subject.endpoint_for(:authorization, "https://foobar.com")
      end
    end

    test "authorization endpoint - finds none for site" do
      html = "<html><head></head></html>"

      use_cassette :stub, uri: "~r/*/", body: html do
        refute Subject.endpoint_for(:authorization, "https://foobar.com")
      end
    end

    test "token endpoint - successfully finds" do
      html =
        "<html><head><link rel='token_endpoint' href='#{@endpoint}' /></head></html>"

      use_cassette :stub, uri: "~r/*/", body: html do
        assert @endpoint = Subject.endpoint_for(:token, "https://foobar.com")
      end

      no_html = "<html></html>"

      use_cassette :stub,
        uri: "~r/*/",
        body: no_html,
        headers: %{"Link" => "<#{@endpoint}>; rel=\"token_endpoint\""} do
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
        "state" => "state"
      }

      obtained_uri = Subject.authenticate(params) |> URI.parse()
      obtained_query_params = URI.decode_query(obtained_uri.query)

      assert %{"state" => "state", "code" => _} = obtained_query_params
    end

    test "successfully generates a signed URI for generating an authorization code" do
      params = %{
        "client_id" => @client_id,
        "me" => @user_profile_url,
        "redirect_uri" => @redirect_uri,
        "response_type" => "code",
        "scope" => "read",
        "state" => "state"
      }

      obtained_uri = Subject.authenticate(params) |> URI.parse()
      obtained_query_params = URI.decode_query(obtained_uri.query)

      assert %{"state" => "state", "code" => _} = obtained_query_params
    end

    test "generate an authorization code when defaulting to edfault 'read' scope" do
      params = %{
        "client_id" => @client_id,
        "me" => @user_profile_url,
        "redirect_uri" => @redirect_uri,
        "response_type" => "code",
        "state" => "state"
      }

      obtained_uri = Subject.authenticate(params) |> URI.parse()
      obtained_query_params = URI.decode_query(obtained_uri.query)

      assert %{"state" => "state", "code" => _} = obtained_query_params
    end
  end
end
