defmodule IndieWeb.HttpTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.Http, as: Subject
  doctest Subject

  setup do
    Application.put_env(:indieweb, :http_adapter, IndieWeb.Test.HttpAdapter, persistent: true)
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
        assert {:ok, %IndieWeb.Http.Response{code: 200}} = Subject.request("https://indieweb.org")
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
end
