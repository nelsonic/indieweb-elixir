defmodule IndieWeb.Auth.ScopeTest do
  use IndieWeb.TestCase, async: true

  setup do
    Application.put_env(:indieweb, :auth_adapter, IndieWeb.Test.AuthAdapter,
      persistent: true
    )
  end

  describe ".persist/2" do
    @describetag skip: true
    test "saves a scope to the adapter"
    test "fails to save a scope to the adapter"
  end

  describe ".get/1" do
    @describetag skip: true
    test "fetches a scope from the adapter"
    test "fails to fetch scope from the adapter"
  end

  describe ".from_string/1" do
    @describetag skip: true
    test "expands a string into a scope list"
  end

  describe ".to_string/1" do
    @describetag skip: true
    test "collapses a scope list into a string"
  end

  describe ".can_upload?/1" do
    @describetag skip: true
    test "determines if a scope can be uploaded"
  end
end
