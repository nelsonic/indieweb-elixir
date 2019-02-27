defmodule IndieWeb.Test.CacheAdapter do
  @moduledoc false
  defdelegate delete(key), to: IndieWeb.Cache.Adapters.Cachex
  defdelegate get(key), to: IndieWeb.Cache.Adapters.Cachex
  defdelegate set(key, value, args), to: IndieWeb.Cache.Adapters.Cachex
end
