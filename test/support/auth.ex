defmodule IndieWeb.Test.AuthAdapter do
  @behaviour IndieWeb.Auth.Adapter
  @code "code"
  @client_id "https://indieauth.client"
  @redirect_uri @client_id <> "/redirect"
  @token "token"
  @me "https://indieauth.me"

  def code, do: @code
  def client_id, do: @client_id
  def redirect_uri, do: @redirect_uri
  def token, do: @token
  def me, do: @me

  def code_generate(_, _, _), do: @code

  def code_verify(_, @client_id <> "_wrong", _, _), do: {:error, :code_mismatch}

  def code_verify(_, _, @redirect_uri <> "_wrong", _),
    do: {:error, :code_mismatch}

  def code_verify(_, _, _, _), do: :ok

  def code_persist(_, _, "fails", _), do: {:error, :test}
  def code_persist(_, _, _, _), do: :ok

  def code_destroy(_, _, _), do: :ok
  def valid_user?(_), do: true

  def scope_get(@code), do: ~w(read)
  def scope_get(@code <> "_no_scope"), do: ~w()
  def scope_get(@code <> "_not_real"), do: ~w()
  def scope_get(_), do: ~w(read)

  def scope_persist(_, _), do: :ok

  def token_generate(_, _), do: @token

  def token_info(@token <> "_wrong_user"), do: {:error, :incorrect_me_for_token}
  def token_info(@token <> "_invalid"), do: {:error, :invalid_token}

  def token_info(@token),
    do: %{"client_id" => @client_id, "me" => @me, "scope" => ~w(read)}

  def token_info(_), do: nil

  def token_revoke(@token <> "_invalid"), do: :error
  def token_revoke(_), do: :ok
end
