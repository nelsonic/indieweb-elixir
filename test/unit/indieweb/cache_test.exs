defmodule IndieWeb.CacheTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.Cache, as: Subject
  doctest Subject

  setup do
    Application.put_env(:indieweb, :cache_adapter, IndieWeb.Test.CacheAdapter, persistent: true)
    :ok
  end

  describe ".adapter/0" do
    test "pulls the one defined in configuration" do
      Application.put_env(:indieweb, :cache_adapter, IndieWeb.Test.CacheAdapter, persistent: true)
      assert Subject.adapter() == IndieWeb.Test.CacheAdapter
    end

    test "defaults to using Cachex" do
      Application.delete_env(:indieweb, :cache_adapter)
      assert Subject.adapter() == IndieWeb.Cache.Adapters.Cachex
    end
  end

  describe ".get/2" do
    @describetag skip: true
    test "defaults to provided value" do
      assert IndieWeb.Cache.get("foo", "default_value") == "default_value"
    end

    test "finds value in cache" do
      IndieWeb.Test.CacheAdapter.set("foo", "in_cache")
      assert IndieWeb.Cache.get("foo") == "in_cache"
    end

    test "nils out if value not found" do
      assert is_nil(IndieWeb.Cache.get("foo"))
    end
  end

  describe ".set/2" do
    @describetag skip: true
    test "adds value to cache" do
      assert IndieWeb.Cache.set("foo", "bar")
      assert IndieWeb.Test.CacheAdapter.get("foo") == "bar"
    end
  end

  describe ".delete/1" do
    @describetag skip: true
    test "removes value from cache" do
      IndieWeb.Test.CacheAdapter.set("foo", "in_cache")
      assert IndieWeb.Cache.delete("foo")
      assert is_nil(IndieWeb.Test.CacheAdapter.get("foo"))
    end
  end
end
