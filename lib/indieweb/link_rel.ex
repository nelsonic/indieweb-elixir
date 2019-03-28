defmodule IndieWeb.LinkRel do
  @moduledoc """
  Provides a normalizer for link information.
  """

  def find(url, value) do
    with(
      {:ok, %IndieWeb.Http.Response{body: body, rels: rels, code: code}}
      when code < 400 <- IndieWeb.Http.get(url)
    ) do
      matching_rel_keys =
        rels
        |> Map.keys()
        |> Enum.filter(fn rel_str ->
          rel_str |> String.split(" ") |> Enum.member?(value)
        end)

      prefetched_rel_values =
        Map.take(rels, matching_rel_keys) |> Map.values() |> List.flatten()

      rel_endpoints =
        case Microformats2.parse(body, url) do
          %{rel_urls: rel_url_map} ->
            Enum.filter(rel_url_map, fn {_url, %{rels: rels}} ->
              value in rels || Enum.any?(rels, &String.contains?(&1, value))
            end)
            |> Enum.map(fn {key, _} -> key end)

          _ ->
            []
        end

      (prefetched_rel_values ++ rel_endpoints)
      |> Enum.map(&do_normalize_url(&1, url))
    else
      _ -> []
    end
  end

  defp do_normalize_url(url, page_url) when is_binary(url) do
    cond do
      # Relative to the site itself.
      String.starts_with?(url, "/") ->
        %{host: host, scheme: scheme} = URI.parse(page_url)
        URI.parse(scheme <> "://" <> host <> url) |> URI.to_string()

      # Relative to the current page's path.
      %{host: nil, scheme: nil} == URI.parse(url) and
          !String.starts_with?(url, "/") ->
        page_url <> "/" <> url

      url == "" ->
        page_url

      # It's good enough!
      true ->
        url
    end
  end
end
