defmodule IndieWeb.Cache.Adapter do
  @moduledoc """
  This provides the interface that adapters should implement if they'd like
  IndieWeb to use it for caching values. Check `IndieWeb` for more information
  and `IndieWeb.Cache.Adapters.Cachex` for more information.
  """

  @doc "Defines the method for obtaining a cached value."
  @callback get(key :: binary()) :: {:ok, any()} | {:error, any()}

  @doc "Defines the method of deleting a cached value."
  @callback delete(key :: binary()) :: :ok | :error

  @doc "Defines the method of setting of a cached value."
  @callback set(key :: binary(), value :: any()) :: :ok | :error
end
