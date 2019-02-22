defmodule IndieWeb.Auth.Token do
  @moduledoc "Manages the token lifecycle for IndieAuth."

  def generate(code, client_id, redirect_uri) do
    with(
      scope when is_binary(scope) <- IndieWeb.Auth.Scope.get(code),
      :ok <- IndieWeb.Auth.Code.verify(code, client_id, redirect_uri, %{"scope" => scope})
    ) do
      IndieWeb.Auth.Code.destroy(client_id, redirect_uri, %{"scope" => scope})
      IndieWeb.Auth.adapter().token_generate(client_id, scope)
    else
      nil -> {:error, :token_generation_failure, reason: :missing_scope}
      {:error, reason} -> {:error, :token_generation_failure, reason: reason}
    end
  end

  def revoke(token) do
    IndieWeb.Auth.adapter().token_revoke(token)
    :ok
  end

  def info_for(token) do
    IndieWeb.Auth.adapter().token_info(token)
  end
end
