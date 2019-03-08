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
    @moduledoc false
    @enforce_keys ~w(target source code)a
    defstruct ~w(target source code status body headers)a
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
    case IndieWeb.LinkRel.find(page_url, "webmention") do
      list when length(list) != 0 ->
        {:ok, List.first(list)}

      _ ->
        {:error, :no_endpoint_found}
    end
  end

  @doc """
  Sends a Webmention to the provided URI.

  This determines the endpoint to send [Webmentions][1] to (using `discover_endpoint/1`) and
  sends the request using the HTTP client provided.

  [1]: https://www.w3.org/TR/webmention
  """
  @spec send(binary(), any()) ::
          {:ok, IndieWeb.Webmention.SendResponse.t()} | {:error, any()}
  def send(target_url, source) do
    with(
      {:ok, endpoint_url} <- discover_endpoint(target_url),
      {:ok, resp} <- direct_send!(endpoint_url, target_url, source)
    ) do
      {:ok, resp}
    else
      {:error, error} -> {:error, :webmention_send_failure, reason: error}
    end
  end

  @doc """
  Sends out a Webmention to the provided `endpoint` for `target` from `source`.
  """
  @spec send(binary(), any()) ::
          {:ok, IndieWeb.Webmention.SendResponse.t()} | {:error, any()}
  def direct_send!(endpoint, target_url, source) do
    with(
      {:ok, source_url} <- resolve_source_url(source),
      {:ok, %IndieWeb.Http.Response{code: code, body: body, headers: headers}}
      when code >= 200 and code < 400 <-
        IndieWeb.Http.post(endpoint,
          body: %{"source" => source_url, "target" => target_url},
          headers: %{"Content-Type" => "application/x-www-form-urlencoded"}
        )
    ) do
      send_resp = %SendResponse{
        target: target_url,
        source: source_url,
        code: code,
        body: body,
        headers: headers,
        status: :accepted
      }

      {:ok, send_resp}
    else
      {:error, error} -> {:error, reason: error}
      {:ok, result} -> {:error, reason: result}
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
        {:ok, [source: source_url, target: target, target_url: target_url]}

      {:error, error} ->
        {:error, :webmention_receive_failure, reason: error}
    end
  end
end
