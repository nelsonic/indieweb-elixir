defmodule IndieWeb.Auth.Adapters.Default do
  @moduledoc "Provides a default implementation of IndieAuth stateful activity."
  @behaviour IndieWeb.Auth.Adapter
  @code_separator "/"
  @code_age 60_000

  @impl true
  def code_generate(client_id, redirect_uri, args) do
    [
      :crypto.strong_rand_bytes(16),
      client_id,
      redirect_uri,
      URI.encode_query(args || %{})
    ]
    |> Enum.map(&Base.url_encode64/1)
    |> Enum.join(@code_separator)
  end

  @impl true
  def code_persist(code, client_id, redirect_uri, args) do
    IndieWeb.Cache.set(
      do_make_key_for_client(client_id, redirect_uri, args),
      code,
      expire: @code_age
    )
  end

  @impl true
  def code_verify(code, client_id, redirect_uri, args) do
    case IndieWeb.Cache.get(
           do_make_key_for_client(client_id, redirect_uri, args)
         ) do
      {:ok, nil} ->
        {:error, :code_not_found}

      {:ok, fetched_code} when is_binary(fetched_code) ->
        [_token, fetched_client_id, fetched_redirect_uri, fetched_args] =
          fetched_code
          |> String.split(@code_separator)
          |> Enum.map(&Base.url_decode64!/1)

        cond do
          code != fetched_code ->
            {:error, :invalid_code}

          fetched_client_id != client_id ->
            {:error, :mismatched_client_id_for_code}

          fetched_redirect_uri != redirect_uri ->
            {:error, :mismatched_redirect_uri_for_code}

          URI.decode_query(fetched_args) != args ->
            {:error, :mismatched_extra_data}

          true ->
            :ok
        end
    end
  end

  @impl true
  def code_destroy(client_id, redirect_uri, args \\ %{}) do
    IndieWeb.Cache.delete(do_make_key_for_client(client_id, redirect_uri, args))
  end

  @impl true
  def scope_get(code) do
    IndieWeb.Cache.get(code, [])
  end

  @impl true
  def scope_persist(code, scope) do
    IndieWeb.Cache.set(code, scope, expire: @code_age)
  end

  @impl true
  def valid_user?(uri) do
    resolve_user_fn =
      Application.get_env(:indieweb, :resolve_user_fn, fn _ -> true end)

    resolve_user_fn.(uri)
  end

  @impl true
  def token_info(token) do
    case IndieWeb.Cache.get(token) do
      {:ok, data} when is_binary(data) -> URI.decode_query(data)
      nil -> {:error, :token_not_found}
    end
  end

  @impl true
  def token_revoke(token) do
    IndieWeb.Cache.delete(token)
  end

  @impl true
  def token_generate(client_id, scope) do
    token = do_make_token(client_id, scope)
    case IndieWeb.Cache.set(token, URI.encode_query(%{"scope" => scope, "client_id" => client_id})) do
      :ok -> {:ok, token}
      error -> {:error, :failed_to_save_token, reason: error}
    end
  end

  defp do_make_key_for_client(client_id, redirect_uri, args) do
    [
      client_id,
      redirect_uri,
      args |> URI.encode_query()
    ]
    |> Enum.join("_")
    |> (fn data -> :crypto.hash(:sha256, data) end).()
  end

  defp do_make_token(client_id, scope) do
    token_data = [
      :crypto.strong_rand_bytes(32),
      client_id,
      scope
    ]
    |> Enum.map(&Base.url_encode64/1)
    |> Enum.join(@code_separator)

    :crypto.hash(:sha256, token_data) |> Base.encode16(case: :lower)
  end
end
