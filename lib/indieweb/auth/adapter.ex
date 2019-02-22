defmodule IndieWeb.Auth.Adapter do
  @moduledoc "Provides an abstraction regarding stateful actions in IndieAuth."

  @callback code_generate(client_id :: binary(), redirect_uri :: binary(), data :: map()) :: binary()
  @callback code_persist(code :: binary(), client_id :: binary(), redirect_uri :: binary(), args :: map()) :: :ok | {:error, any()}
  @callback code_destroy(client_id :: binary(), redirect_uri :: binary(), args :: map()) :: :ok
  @callback code_verify(binary(), binary(), binary(), map()) :: :ok | {:error, any()}
  @callback scope_get(code :: binary()) :: binary() | nil
  @callback scope_persist(code :: binary(), scope :: binary()) :: :ok | {:error, any()}
  @callback valid_user?(uri :: binary()) :: boolean()
  @callback token_generate(binary(), binary()) :: binary()
  @callback token_info(binary()) :: nil | {:error, any()} | map()
  @callback token_revoke(binary()) :: :ok
end
