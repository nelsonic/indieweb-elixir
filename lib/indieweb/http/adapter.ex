defmodule IndieWeb.Http.Adapter do
  @callback
  def request(method, uri, opts)
end
