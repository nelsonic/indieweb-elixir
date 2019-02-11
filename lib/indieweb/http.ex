defmodule IndieWeb.Http do
  def adapter, do: Application.get_env(:indieweb, :http_adapter, IndieWeb.Http.Adapters.HTTPotion)

  def request(uri, method \\ :get, opts \\ []) do
    adapter().request(uri, method, opts)
  end

  for method <- ~w(get post options head put patch delete)a do
    def unquote(method)(uri, opts), do: IndieWeb.Http.request(uri, unquote(method), opts)
  end
end
