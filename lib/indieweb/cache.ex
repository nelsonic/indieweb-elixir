defmodule IndieWeb.Cache do
  def adapter, do: Application.get_env(:indieweb, :cache_adapter, IndieWeb.Cache.Adapters.Cachex)

  def get(key, value \\ nil), do: adapter().get(key) || value
  def delete(key), do: adapter().delete(key)
  def set(key, value), do: adapter().set(key, value)
end
