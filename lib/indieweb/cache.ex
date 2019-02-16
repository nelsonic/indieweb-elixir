defmodule IndieWeb.Cache do
  @moduledoc """
  Provides the generic interface for handling caching logic in Koype.

  ## Configuration
  In order to change the underlying adapter used, set the `:cache_adapter` value to an
  implementation of `IndieWeb.Cache.Adapter`. By default, `Cachex` by way of
  `IndieWeb.Cache.Adapters.Cachex` is used.
  """

  @doc "Obtains an implementation of a `IndieWeb.Cache.Adapter` module."
  @spec adapter() :: IndieWeb.Cache.Adapter.t
  def adapter, do: Application.get_env(:indieweb, :cache_adapter, IndieWeb.Cache.Adapters.Cachex)

  @doc "Fetches the value defined by `key` from the adapter; returning `value` if it doesn't exist."
  @spec get(binary(), any()) :: any() | nil
  def get(key, value \\ nil), do: adapter().get(key) || value

  @doc "Removes the value of key `key` from the adapter."
  @spec delete(binary()) :: :ok | :error
  def delete(key), do: adapter().delete(key)

  @doc "Sets the key `key` with the value `value` to the adapter."
  @spec set(binary(), any()) :: :ok | :error
  def set(key, value), do: adapter().set(key, value)
end
