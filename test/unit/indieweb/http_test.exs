defmodule IndieWeb.HttpTest do
  use IndieWeb.TestCase, async: false
  use IndieWeb.HttpMock
  alias IndieWeb.Http, as: Subject
  doctest Subject

  describe ".request/2" do
    test "successfully sends a HTTP GET request by default" do
      use_cassette :stub, uri: "~r/*", method: :get do
        assert {:ok, %Subject.Response{code: 200}} =
                 Subject.request("https://indieweb.org")
      end
    end

    for method <- ~w(get post options head put patch delete)a do
      test "successfully sends a HTTP #{method} request" do
        use_cassette :stub, uri: "~r/*", method: unquote(method) do
          assert {:ok, resp} =
                   Subject.request("https://indieweb.org", unquote(method))

          assert {:ok, %Subject.Response{}} =
                   Subject.unquote(method)("https://indieweb.org")
        end
      end
    end
  end

  describe ".post_encoded/2" do
    test "sends a encoded request" do
      assert {:ok, resp} =
               Subject.post_encoded("http://httpbin.org/anything",
                 body: %{"test" => "data"}
               )

      Apex.ap(resp)
    end
  end

  describe ".extract_link_rel_from_headers/1" do
    # TODO: There's a bug in Telsa that doesn't allow for multiple rel values.
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
              "<https://v2.jacky.wtf>; rel=\"self\", " <>
              "<https://v2.jacky.wtf/api/indie/token>; rel=\"token_endpoint\""
        } do
        assert {:ok, resp} = IndieWeb.Http.head("https://v2.jacky.wtf")
        assert values = IndieWeb.Http.extract_link_header_values(resp)
        assert %{"self" => "https://v2.jacky.wtf"} = values

        assert %{
                 "me" => "https://www.instagram.com/jackyalcine/"
               } = values
      end
    end
  end
end
