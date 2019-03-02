defmodule Microformats2.Utility do
  @moduledoc false

  def get_format(mf2, format) do
    case Enum.fetch(extract(mf2, format), 0) do
      {:ok, mf2} -> mf2
      _ -> nil
    end
  end

  def get_value(mf2, property, default_value \\ [])

  def get_value(%{properties: properties}, property, default_value) do
    Map.get(properties, property, default_value)
  end

  def get_value(_, _, _), do: {:error, :no_properties}

  def fetch(uri) do
    with(
      {:ok, resp} <- IndieWeb.Http.get(uri),
      mf2 when is_map(mf2) <- Microformats2.parse(resp.body, uri)
    ) do
      {:ok, mf2}
    else
      error -> {:error, :remote_mf2_fetch_failed, reason: error}
    end
  end

  def extract(mf2) when is_map(mf2) do
    mf2 |> Map.take(~w(items children)a) |> Map.values() |> List.flatten()
  end

  def extract(_), do: []

  def extract_deep(mf2) when is_map(mf2) do
    items = extract(mf2) ++ do_extract_from_properties(mf2)
    children = items |> Enum.map(&extract_deep/1) |> List.flatten()

    items ++ children
  end

  def extract_deep(_), do: []

  def extract_deep(mf2, type) do
    mf2 |> extract_deep |> Enum.filter(&matches_type?(&1, type))
  end

  def extract(mf2, type) do
    mf2 |> extract |> Enum.filter(&matches_type?(&1, type))
  end

  def matches_type?(mf2, type) when is_map(mf2) do
    Enum.member?(Map.get(mf2, :type, []), "h-#{type}")
  end

  def matches_type?(_, _), do: false

  defp do_extract_from_properties(%{properties: properties}) do
    Enum.map(properties, fn {_, items} ->
      Enum.map(items, fn
        item when is_map(item) ->
          item

        _ ->
          nil
      end)
    end)
    |> List.flatten()
  end

  defp do_extract_from_properties(_), do: []
end
