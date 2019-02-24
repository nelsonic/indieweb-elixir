defmodule IndieWeb.Auth.Scope do
  @moduledoc """
  Handles scope information and referencing for the IndieAuth flow.
  """

  @spec persist!(binary(), binary()) :: :ok
  def persist!(code, scope) do
    :ok = IndieWeb.Auth.adapter().scope_persist(code, scope)
  end

  @spec get(binary()) :: binary() | nil
  def get(code) do
    IndieWeb.Auth.adapter().scope_get(code)
  end
end
