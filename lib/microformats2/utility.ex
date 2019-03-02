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

  def extract(mf2, format) do
    items =
      mf2
      |> Map.take(~w(items children)a)
      |> Map.values()
      |> List.flatten()
      |> Enum.filter(&Enum.member?(Map.get(&1, :type, []), "h-#{format}"))

    items
  end

  def fetch(uri) do
    with(
      {:ok, %IndieWeb.Http.Response{body: body, code: code}}
      when code >= 200 and code < 300 <- IndieWeb.Http.get(uri),
      mf2 when is_map(mf2) <- Microformats2.parse(body, uri)
    ) do
      {:ok, mf2}
    else
      _ -> {:error, :remote_mf2_fetch_failed}
    end
  end
end
