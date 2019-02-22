defmodule IndieWeb.Auth.Adapters.Default do
  @behaviour IndieWeb.Auth.Adapter
  @code_separator "/"
  @code_age 60_000

  def code_generate(client_id, redirect_uri, args) do
    [
      :crypto.strong_rand_bytes(8),
      client_id,
      redirect_uri,
      URI.decode_query(args)
    ]
    |> Enum.map(&Base.url_encode64/1)
    |> Enum.join(@code_separator)
  end

  def code_persist(code, client_id, redirect_uri) do
    IndieWeb.Cache.set(do_make_key_for_client(client_id, redirect_uri), code, expire: @code_age)
  end

  def code_verify(code, client_id, redirect_uri, args) do
    case IndieWeb.Cache.get(do_make_key_for_client(client_id, redirect_uri)) do
      {:ok, nil} ->
        {:error, :code_not_found}

      {:ok, fetched_code} when is_binary(fetched_code) ->
        [_token, fetched_client_id, fetched_redirect_uri, fetched_args] =
          String.split(fetched_code, @code_separator)
          |> Enum.map(fn value -> Base.url_decode64(value) end)
          |> Enum.map(fn {:ok, value} -> value end)

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

  defp do_make_key_for_client(client_id, redirect_uri) do
    [
      client_id,
      redirect_uri
    ]
    |> Enum.join("_")
  end
end
