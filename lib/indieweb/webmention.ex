defmodule IndieWeb.Webmention do
  @moduledoc """
  Handles Webmention interoperability for a site.
  """

  @doc """
  Finds the Webmention endpoint of the provided URI.

  This employs the [Webmention endpoint discovery algorithm][1] to find
  the proper endpoint to send Webmentions for the URI in question.

  [1]: https://www.w3.org/TR/webmention/#sender-discovers-receiver-webmention-endpoint

  TODO: Add User-Agent information.
  """
  @spec discover_endpoint(binary) :: {:ok, binary()} | {:error, any()}
  def discover_endpoint(page_url) do
    with(
      {:ok, %IndieWeb.Http.Response{code: code, headers: headers, body: body}}
      when code < 299 and code >= 200 <- IndieWeb.Http.get(page_url),
      %{rels: rels} = page_mf2 when is_map(page_mf2) <- Microformats2.parse(body, page_url)
    ) do
      webmention_uris = Map.get(rels, "webmention", []) || []
      uris = do_extraction_from_headers(headers) ++ webmention_uris

      if uris == [] do
        {:error, :no_endpoint_found}
      else
        IO.puts(inspect(uris))
        uri = uris |> List.first |> do_normalize_webmention_endpoint_uri(page_url)
        {:ok, uri}
      end
    else
      _ -> {:error, :no_endpoint_found}
    end
  end

  defp do_extraction_from_headers(headers) when is_map(headers) do
    links = Map.take(headers, ["link", "Link"]) |> Map.values() |> List.flatten()
    IO.puts(inspect(links))

    if !Enum.empty?(links) do
      Enum.map(links, fn link ->
        link
        |> String.split(",")
        |> Enum.map(fn v ->
          String.split(v, ";") |> Enum.map(fn f -> String.trim(f) end)
        end)
        |> Enum.filter(fn [_, rel | _] -> String.contains?(rel, "webmention") end)
        |> Enum.map(fn webmention_link_rel ->
          webmention_link_rel
          |> Enum.drop(-1)
          |> Enum.map(&(String.slice(&1, 1..-2)))
        end)
      end)
      |> List.flatten()
    else
      []
    end
  end

  defp do_extraction_from_headers(_), do: nil

  defp do_normalize_webmention_endpoint_uri(url, page_url) when is_binary(url) do
      cond do
        # Relative to the site itself.
        String.starts_with?(url, "/") ->
          %{host: host, scheme: scheme} = URI.parse(page_url)
          URI.parse(scheme <> "://" <> host <> url) |> URI.to_string()

        # Relative to the current page's path.
        %{host: nil, scheme: nil} == URI.parse(url) and !String.starts_with?(url, "/") ->
          page_url <> "/" <> url

        url == "" -> page_url

        # It's good enough!
        true ->
          url
      end
  end
end
