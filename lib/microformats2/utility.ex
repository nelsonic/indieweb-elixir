defmodule Microformats2.Utiltiy do
  def get_format(mf2, format) do
    case Enum.fetch(extract_all(mf2, format), 0) do
      {:ok, mf2} -> mf2
      _ -> nil
    end
  end

  def get_value(mf2, property, default_value \\ [])

  def get_value(%{"properties" => properties}, property, default_value) do
    Map.get(properties, property, default_value)
  end

  def get_value(_, _, _), do: {:error, :no_properties}

  def extract_all(mf2, format) do
    items = Map.take(mf2, ~w(items children)) |> Map.values() |> List.flatten()
    Stream.flat_map(items, fn item -> do_parse_item(item, format) end)
  end

  defp do_parse_item(item, format) do
    types = Map.get(item, "type", [])

    if Enum.member?(types, "h-#{format}") do
      [item]
    else
      Stream.concat(do_extract_from_properties(item, format), extract_all(item, format))
    end
  end

  defp do_extract_from_properties(%{"properties" => properties}, format) do
    Stream.flat_map(properties, fn
      {prop, items} ->
        Stream.flat_map(items, fn
          item when is_map(item) ->
            do_parse_item(item, format)

          _ ->
            []
        end)
    end)
  end

  defp do_extract_from_properties(_, _), do: []
end
