defmodule IndieWeb.Cache.Adapters.Cachex do
  def get(key) do
    case Cachex.get(:indieweb, key) do
      {:ok, value} when not(is_nil(value)) -> value
      _ -> nil
    end
  end

  def delete(key) do
    case Cachex.del(:indieweb, key) do
      {:ok, _} -> :ok
      _ -> :error
    end
  end

  def set(key, value) do
    case Cachex.put(:indieweb, key, value) do
      {:ok, _} -> :ok
      _ -> :error
    end
  end
end
