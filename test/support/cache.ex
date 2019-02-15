defmodule IndieWeb.Test.CacheAdapter do
  defdelegate delete(key), to: IndieWeb.Cache.Adapters.Cachex
  defdelegate get(key), to: IndieWeb.Cache.Adapters.Cachex
  defdelegate set(key, value), to: IndieWeb.Cache.Adapters.Cachex
end

Application.put_env(:indieweb, :cache_adapter, IndieWeb.Test.CacheAdapter, persistent: true)
