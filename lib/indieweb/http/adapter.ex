defmodule IndieWeb.Http.Adapter do
  @moduledoc "Provides an abstraction on handling HTTP actions."
  @doc "Defines the method for making a general HTTP request."
  @callback request(uri :: binary(), method :: atom(), opts :: keyword()) :: {:ok, IndieWeb.Http.Response.t} | {:error, IndieWeb.Http.Error.t}
end
