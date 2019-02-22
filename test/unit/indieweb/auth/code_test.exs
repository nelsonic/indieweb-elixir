defmodule IndieWeb.Auth.CodeTest do
  use IndieWeb.TestCase, async: false
  alias IndieWeb.Auth.Code, as: Subject

  setup do
    Application.put_env(:indieweb, :auth_adapter, IndieWeb.Test.AuthAdapter, persistent: true)
  end

  describe ".generate/2" do
    test "provides a new code" do
      assert :ok = Subject.persist("code", "https://indieauth.code", "https://indieauth.code/redirect")
    end
  end

  describe ".persist/3" do
    test "saves the provided code for the client & redirect_uri" do
      assert :ok = Subject.persist("code", "https://indieauth.persist", "https://indieauth.persists/redirect")
      assert {:error, :test} = Subject.persist("code", "https://indieauth.persist", "fails")
    end
  end

  describe ".verify/3" do
    test "confirms if a code was stored for this value with no data" do
      assert :ok = Subject.verify("code", "https://indieauth.code", "https://indieauth.code/foo")
    end

    test "confirms if a code was stored for this value with data" do
      assert :ok = Subject.verify("code", "https://indieauth.code", "https://indieauth.code/foo", %{"prop" => "val"})
    end
  end
end
