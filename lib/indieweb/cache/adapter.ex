defmodule IndieWeb.Cache.Adapter do
  @callback
  def get(key)

  @callback
  def delete(key)

  @callback
  def set(key, value)
end
