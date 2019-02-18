defmodule IndieWeb.Http do
  @moduledoc """
  Provides a facade for handling HTTP actions.
  """

  def timeout, do: 10_000

  @doc "Obtains an implementation of a `IndieWeb.Http.Adapter` module."
  @spec adapter() :: IndieWeb.HTTP.Adapter.t
  def adapter, do: Application.get_env(:indieweb, :http_adapter, IndieWeb.Http.Adapters.HTTPotion)

  @doc "Sends a HTTP request to the URI `uri` with the provided options."
  @spec request(binary(), atom(), keyword()) :: {:ok, IndieWeb.Http.Response.t} | {:error, IndieWeb.Http.Error.t}
  def request(uri, method \\ :get, opts \\ []) do
    adapter().request(uri, method, opts)
  end

  for method <- ~w(get post options head put patch delete)a do
    @doc """
    Sends a #{String.upcase(Atom.to_string(method))} request to the specified URI.
    
    See `request/3` for more information about making requests.
    """
    def unquote(method)(uri, opts \\ []), do: IndieWeb.Http.request(uri, unquote(method), opts)
  end
end
