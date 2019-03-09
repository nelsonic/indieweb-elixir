defmodule IndieWeb.App.Link do
  @behaviour IndieWeb.App.Parser
  @moduledoc false

  defp do_fetch(uri) do
    with(
      {:ok, %IndieWeb.Http.Response{body: body}} <- IndieWeb.Http.get(uri),
      %{items: _, rel_urls: _, rels: rels} when is_map(rels) and rels != %{} <-
        Microformats2.parse(body, uri)
    ) do
      {:ok, Map.put(rels, "url", uri)}
    else
      _ ->
        {:ok, %{}}

      {:error, _} ->
        false
    end
  end

  defp do_format(%{"url" => url} = rels) do
    app_data = %{
      "logo" => Map.get(rels, "icon", [""]) |> List.last(),
      "name" => URI.parse(url).host,
      "url" => url
    }

    {:ok, app_data}
  end

  defp do_format(_), do: {:error, :no_useful_link_data}

  @impl true
  def resolve(uri) do
    case do_fetch(uri) do
      {:ok, link_data} -> do_format(link_data)
      false -> {:error, :failed_to_fetch_link_data}
    end
  end

  @impl true
  def clear(_), do: :ok
end
