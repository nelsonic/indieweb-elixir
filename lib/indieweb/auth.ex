defmodule IndieWeb.Auth do
  @moduledoc """
  Provides logic for handling [IndieAuth](https://indieauth.spec.indieweb.org) interactions.
  """
  def adapter(), do: Application.get_env(:indieweb, :auth_adapter, IndieWeb.Auth.Adapters.Default)

  defmodule Adapter do
    @callback code_generate(client_id :: binary(), redirect_uri :: binary(), data :: map()) :: binary()
    @callback code_persist(code :: binary(), client_id :: binary(), redirect_uri :: binary()) :: :ok | {:error, any()}
    @callback scope_persist(code :: binary(), scope :: binary()) :: :ok | {:error, any()}
    @callback valid_user?(uri :: binary()) :: boolean()
  end

  @doc "Provides endpoint information for well known endpoints in IndieAuth."
  @spec endpoint_for(atom(), binary()) :: binary() | nil
  def endpoint_for(type, uri)

  def endpoint_for(component, url) when component in ~w(authorization token)a do
    IndieWeb.LinkRel.find(url, "#{component}_endpoint") |> List.first()
  end

  def endpoint_for(:redirect_uri, url), do: IndieWeb.LinkRel.find(url, "redirect_uri")
  def endpoint_for(_, _), do: nil

  @spec authenticate(map()) :: {:ok, any()} | {:error, any()}
  def authenticate(params)

  def authenticate(%{"response_type" => "id"} = params) do
    case do_validate_request(params, ~w(client_id redirect_uri state me)) do
      {:error, _} = error ->
        error

      {:ok, %{"client_id" => client_id, "redirect_uri" => redirect_uri, "state" => state}} ->
        code = IndieWeb.Auth.Code.generate(client_id, redirect_uri)
        do_generate_redirect_uri(redirect_uri, code, state)
    end
  end

  def authenticate(%{"response_type" => "code"} = params) do
    case do_validate_request(params, ~w(client_id redirect_uri state me)) do
      {:error, _} = error ->
        error

      {:ok, %{"client_id" => client_id, "redirect_uri" => redirect_uri, "state" => state} = args} ->
        scope = Map.get(args, "scope", "read")
        code = IndieWeb.Auth.Code.generate(client_id, redirect_uri, %{"scope" => scope})
        do_generate_redirect_uri(redirect_uri, code, state)
    end
  end

  def authenticate(_), do: {:error, :unrecognized_authorization_request}

  defp do_generate_redirect_uri(redirect_uri, code, state) do
    query =
      redirect_uri
      |> URI.parse()
      |> Map.get(:query)
      |> (&(URI.decode_query(&1 || "", %{"code" => code, "state" => state}) |> URI.encode_query())).()

    redirect_uri
    |> URI.parse()
    |> Map.put(:query, query)
    |> URI.to_string()
  end

  defp do_validate_request(params, expected_keys) do
    proper_args = Map.take(params, expected_keys)
    missing_keys = expected_keys -- Map.keys(params)

    cond do
      !Enum.empty?(missing_keys) ->
        {:error, :missing_required_keys, keys: missing_keys}

      !adapter().valid_user?(params["me"]) ->
        {:error, :invalid_user}

      true ->
        {:ok, proper_args}
    end
  end
end
