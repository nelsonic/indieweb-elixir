defmodule IndieWeb.HttpTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.Http, as: Subject
  doctest Subject

  setup do
    Application.put_env(:indieweb, :http_adapter, IndieWeb.Test.HttpAdapter,
      persistent: true
    )

    :ok
  end

  describe ".adapter/0" do
    test "pulls the one defined in configuration" do
      assert Subject.adapter() == IndieWeb.Test.HttpAdapter
    end

    test "defaults to using HTTPotion" do
      Application.delete_env(:indieweb, :http_adapter)
      assert Subject.adapter() == IndieWeb.Http.Adapters.HTTPotion
    end
  end

  describe ".request/2" do
    test "successfully sends a HTTP GET request by default" do
      use_cassette :stub, uri: "~r/*", method: :get do
        assert {:ok, %IndieWeb.Http.Response{code: 200}} =
                 Subject.request("https://indieweb.org")
      end
    end

    for method <- ~w(get post options head put patch delete)a do
      test "successfully sends a HTTP #{method} request" do
        use_cassette :stub, uri: "~r/*", method: unquote(method) do
          assert {:ok, %IndieWeb.Http.Response{}} =
                   Subject.request("https://indieweb.org", unquote(method))

          assert {:ok, %IndieWeb.Http.Response{}} =
                   Subject.unquote(method)("https://indieweb.org")
        end
      end
    end
  end

  describe ".extract_link_rel_from_headers/1" do
    test "extracts values from response" do
      use_cassette :stub,
        uri: "~r/*/",
        method: "head",
        headers: %{
          "link" =>
            "<https://v2.jacky.wtf/indie/auth>; rel=\"authorization_endpoint\", " <>
              "<https://playvicious.social/@jalcine>; rel=\"me\", " <>
              "<https://twitter.com/jackyalcine>; rel=\"me\", " <>
              "<https://www.instagram.com/jackyalcine/>; rel=\"me\", " <>
              "<https://v2.jacky.wtf/api/indie/micropub/media>; rel=\"media_endpoint\", " <>
              "<https://v2.jacky.wtf/api/indie/micropub>; rel=\"micropub\", " <>
              "<https://aperture.p3k.io/microsub/175>; rel=\"microsub\", " <>
              "<https://v2.jacky.wtf>; rel=\"self\", " <>
              "<https://v2.jacky.wtf/api/indie/token>; rel=\"token_endpoint\""
        } do
        assert {:ok, resp} = IndieWeb.Http.head("https://v2.jacky.wtf")
        assert values = IndieWeb.Http.extract_link_header_values(resp.headers)
        assert %{"self" => ["https://v2.jacky.wtf"]} = values

        assert %{
                 "me" => [
                   "https://playvicious.social/@jalcine",
                   "https://twitter.com/jackyalcine",
                   "https://www.instagram.com/jackyalcine/"
                 ]
               } = values
      end
    end
  end
end
