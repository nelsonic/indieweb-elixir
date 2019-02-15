defmodule IndieWeb.Http.Adapter do
  @callback request(uri :: binary(), method :: atom(), opts :: keyword()) :: {:ok, IndieWeb.Http.Response.t} | {:error, IndieWeb.Http.Error.t}
end
