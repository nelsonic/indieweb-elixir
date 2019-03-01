defmodule IndieWeb.CacheTest do
  use IndieWeb.TestCase, async: true
  alias IndieWeb.Cache, as: Subject
  doctest Subject

  describe ".adapter/0" do
    test "defaults to using Cachex" do
      assert Subject.adapter() == IndieWeb.Cache.Adapters.Cachex
    end
  end

  describe ".get/2" do
    @describetag skip: true
    test "defaults to provided value" do
      assert "default_value" =
               IndieWeb.Cache.get("foo_not_found", "default_value")
    end

    test "finds value in cache" do
      IndieWeb.Cache.set("foo", "in_cache", [])
      assert "in_cache" = IndieWeb.Cache.get("foo")
    end

    test "nils out if value not found" do
      refute IndieWeb.Cache.get("foo_not_found")
    end
  end

  describe ".set/2" do
    test "adds value to cache" do
      assert IndieWeb.Cache.set("foo", "bar")
      assert "bar" = IndieWeb.Cache.get("foo")
    end
  end

  describe ".delete/1" do
    test "removes value from cache" do
      assert IndieWeb.Cache.set("foo", "in_cache", [])
      assert IndieWeb.Cache.delete("foo")
      assert is_nil(IndieWeb.Cache.get("foo"))
    end
  end
end
