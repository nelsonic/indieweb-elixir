defmodule IndieWeb.Cache.Adapters.Cachex do
  @behaviour IndieWeb.Cache.Adapter
  @moduledoc """
  Wraps logic for using `Cachex` as the caching mechanism in `IndieWeb`.

  NOTE: This uses the cache name `indieweb`.
  """

  @impl true
  def get(key) do
    result = Cachex.get(:indieweb, key)

    case result do
      {:ok, value} when not is_nil(value) -> value
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
          {:ok, true} =
            Cachex.expire(:indieweb, key, :timer.seconds(options[:expire]))
        end

        :ok

      err ->
        {:error, err}
    end
  end
end
