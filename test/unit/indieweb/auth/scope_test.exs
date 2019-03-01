defmodule IndieWeb.Auth.ScopeTest do
  use IndieWeb.TestCase, async: true
  alias IndieWeb.Auth.Scope, as: Subject
  @code "a_code"

  describe ".get/1" do
    test "finds stored scope info" do
      IndieWeb.Cache.set(@code, "read")
      assert ~w(read) == Subject.get(@code)
    end

    test "returns nil for non-existent code-to-scope" do
      assert nil == Subject.get(@code <> "_not_real")
    end
  end

  describe ".persist!/2" do
    test "saves provided scope" do
      assert :ok = Subject.persist!(@code, "read")
      assert ~w(read) = Subject.get(@code)
    end

    test "saves default code of read" do
      assert :ok = Subject.persist!(@code, "")
      assert ~w(read) = Subject.get(@code)
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
