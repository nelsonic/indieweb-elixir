defmodule IndieWeb.Cache.Adapters.Cachex do
  @behaviour IndieWeb.Cache.Adapter
  @moduledoc """
  Wraps logic for using `Cachex` as the caching mechanism in `IndieWeb`.

  NOTE: This uses the cache name `indieweb`.
  """

  @impl true
  def get(key) do
    case Cachex.get(:indieweb, key) do
      {:ok, value} = resp when not is_nil(value) -> resp
      _ -> nil
    end
  end

  @impl true
  def delete(key) do
    case Cachex.del(:indieweb, key) do
      {:ok, _} -> :ok
      err -> {:error, err}
    end
  end

  @impl true
  def set(key, value, options \\ []) do
    case Cachex.put(:indieweb, key, value) do
      {:ok, _} ->
        if Keyword.has_key?(options, :expire) do
          {:ok, _} = Cachex.expire(:indieweb, key, options[:expire])
        end

        :ok

      err -> {:error, err}
    end
  end
end
