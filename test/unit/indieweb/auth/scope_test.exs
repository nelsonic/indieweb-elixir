defmodule IndieWeb.Auth.ScopeTest do
  use IndieWeb.TestCase, async: true
  alias IndieWeb.Auth.Scope, as: Subject
  @code IndieWeb.Test.AuthAdapter.code()

  setup do
    Application.put_env(:indieweb, :auth_adapter, IndieWeb.Test.AuthAdapter,
      persistent: true
    )
  end


  describe ".get/1" do
    test "finds stored scope info" do
      assert ~w(read) == Subject.get(@code)
    end

    test "returns empty for code with no scope" do
      assert ~w() == Subject.get(@code <> "_no_scope")
    end

    test "returns empty for non-existent code-to-scope" do
      assert ~w() == Subject.get(@code <> "_not_real")
    end
  end

  describe ".persist!/2" do
    test "saves provided scope when it's a string" do
      assert :ok = Subject.persist!(@code, "read")
    end

    test "saves default code of read" do
      assert :ok = Subject.persist!(@code, ~w())
    end
  end

  describe ".can_upload?/1" do
    test "confirms provided list of scopes has a scope for uploading" do
      assert Subject.can_upload?(~w(media read))
    end

    test "denies provided list of scopes for uploading" do
      refute Subject.can_upload?(~w(read))
    end
  end
end
