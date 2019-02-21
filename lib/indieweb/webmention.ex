defmodule IndieWeb.Webmention do
  @moduledoc """
  Handles Webmention interoperability for a site.
  """

  defmodule URIAdapter do
    @moduledoc """
    Facility for handling URI generation of Webmention logic.
    """
    @doc "Defines a means of generating a URI from the provided value."
    @callback to_source_url(object :: any()) :: {:ok, URI.t()} | {:error, any()}

    @doc "Defines a means of obtaining a target from a URI."
    @callback from_source_url(uri :: URI.t()) :: {:ok, any()} | {:error, any()}
  end

  defmodule SendResponse do
    @enforce_keys ~w(target source code)a
    defstruct ~w(target source code status)a
  end

  @doc "Defines the adpater to use to resolve URI and source content."
  @spec url_adapter() :: __MODULE__.URIAdapter.t()
  def url_adapter, do: Application.get_env(:indieweb, :webmention_url_adapter)

  def resolve_target_from_url(target_url) do
    if url_adapter() != nil do
      case url_adapter().from_source_url(target_url) do
        nil -> {:error, :no_target}
        target -> {:ok, target}
      end
    else
      {:error, :no_adapter}
    end
  end

  def resolve_source_url(source) do
    if url_adapter() != nil do
      case url_adapter().to_source_url(source) do
        nil -> {:error, :no_source}
        %URI{} = url -> {:ok, url}
        _ -> {:error, :invalid_url}
      end
    else
      {:error, :no_adapter}
    end
  end

  @doc """
  Finds the Webmention endpoint of the provided URI.

  This employs the [Webmention endpoint discovery algorithm][1] to find
  the proper endpoint to send Webmentions for the URI in question.

  [1]: https://www.w3.org/TR/webmention/#sender-discovers-receiver-webmention-endpoint

  TODO: Add User-Agent information (by allowing to pass in header options)
  """
  @spec discover_endpoint(binary) :: {:ok, binary()} | {:error, any()}
  def discover_endpoint(page_url) do
    with(
      {:ok, %IndieWeb.Http.Response{code: code, headers: headers, body: body}}
      when code < 299 and code >= 200 <- IndieWeb.Http.get(page_url),
      %{rels: rels} = page_mf2 when is_map(page_mf2) <- Microformats2.parse(body, page_url)
    ) do
      webmention_uris = Map.get(rels, "webmention", []) || []

      header_webmention_uris = headers |> IndieWeb.Http.extract_link_header_values() |> Map.get("webmention", [])

      uris = header_webmention_uris ++ webmention_uris

      if uris == [] do
        {:error, :no_endpoint_found}
      else
        uri = uris |> List.first() |> do_normalize_webmention_endpoint_uri(page_url)
        {:ok, uri}
      end
    else
      _ -> {:error, :no_endpoint_found}
    end
  end

  @doc """
  Sends a Webmention to the provided URI.

  This determines the endpoint to send [Webmentions][1] to (using `discover_endpoint/1`) and
  sends the request using the HTTP client provided.

  [1]: https://www.w3.org/TR/webmention
  """
  @spec send(binary(), any()) :: {:ok, IndieWeb.Webmention.SendResponse.t()} | {:error, any()}
  def send(target_url, source) do
    with(
      {:ok, source_url} <- resolve_source_url(source),
      {:ok, endpoint_url} <- discover_endpoint(target_url),
      {:ok, resp} <-
        IndieWeb.Http.post(endpoint_url,
          body: %{"source" => source_url, "target" => target_url},
          headers: %{"Content-Type" => "application/x-www-form-urlencoded"}
        )
    ) do
      send_resp = %SendResponse{
        target: target_url,
        source: source_url,
        code: resp.code,
        status: :accepted
      }

      {:ok, send_resp}
    else
      {:error, error} -> {:error, :webmention_send_failure, reason: error}
    end
  end

  @doc """
  Parses properties of an incoming Webmention.

  This aims to resolve the target of an incoming Webmention and determine if there's
  a valid action to take from it.
  """
  @spec receive(map()) :: {:ok, [action: atom(), args: map()]} | {:error, any()}
  def receive([source: source_url, target: target_url] = _args) do
    case resolve_target_from_url(target_url) do
      {:ok, target} ->
        {:ok, [from: source_url, target: target]}

      {:error, error} ->
        {:error, :webmention_receive_failure, reason: error}
    end
  end

  defp do_normalize_webmention_endpoint_uri(url, page_url) when is_binary(url) do
    cond do
      # Relative to the site itself.
      String.starts_with?(url, "/") ->
        %{host: host, scheme: scheme} = URI.parse(page_url)
        URI.parse(scheme <> "://" <> host <> url) |> URI.to_string()

      # Relative to the current page's path.
      %{host: nil, scheme: nil} == URI.parse(url) and !String.starts_with?(url, "/") ->
        page_url <> "/" <> url

      url == "" ->
        page_url

      # It's good enough!
      true ->
        url
    end
  end
end
