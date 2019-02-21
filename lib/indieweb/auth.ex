defmodule IndieWeb.Auth do
  @moduledoc """
  Provides basic logic for handling [IndieAuth](https://indieauth.spec.indieweb.org) interactions.
  """

  @doc "Provides endpoint information for well known endpoints in IndieAuth."
  @spec endpoint_for(atom(), binary()) :: binary() | nil
  def endpoint_for(type, uri)

  def endpoint_for(component, url) when component in ~w(authorization media token)a do
    with(
      {:ok, %IndieWeb.Http.Response{code: code, body: body, headers: headers}} when code < 299 and code >= 200 <- IndieWeb.Http.get(url)
    ) do
      endpoints = IndieWeb.Http.extract_link_header_values(headers) |> Map.get("#{component}_endpoint", [])
        rel_endpoints = case Microformats2.parse(body, url) do
          %{rels: rel_map} -> Map.get(rel_map, "#{component}_endpoint", [])
          _ -> []
        end
        List.first(rel_endpoints ++ endpoints)
    else
      _ -> nil
    end
  end

  def endpoint_for(_, _), do: nil
end
