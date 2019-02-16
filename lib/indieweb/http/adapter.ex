defmodule IndieWeb.Http.Adapter do
  @doc "Defines the method for making a general HTTP request."
  @callback request(uri :: binary(), method :: atom(), opts :: keyword()) :: {:ok, IndieWeb.Http.Response.t} | {:error, IndieWeb.Http.Error.t}
end
