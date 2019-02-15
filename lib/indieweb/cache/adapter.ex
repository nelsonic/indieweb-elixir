defmodule IndieWeb.Cache.Adapter do
  @callback get(key :: binary()) :: {:ok, any()} | {:error, any()}
  @callback delete(key :: binary()) :: :ok | :error
  @callback set(key :: binary(), value :: any()) :: :ok | :error
end
