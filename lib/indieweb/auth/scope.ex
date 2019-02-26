defmodule IndieWeb.Auth.Scope do
  @moduledoc """
  Handles scope information and referencing for the IndieAuth flow.
  """

  @spec persist!(binary(), binary()) :: :ok
  def persist!(code, scope) do
    IndieWeb.Auth.adapter().scope_persist(code, scope)
  end

  @spec get(binary()) :: binary() | nil
  def get(code) do
    IndieWeb.Auth.adapter().scope_get(code)
  end

  def from_string(scope_string) when is_binary(scope_string),
    do: String.split(scope_string, @separator)

  def to_string(scopes) when is_list(scopes),
    do: Enum.join(scopes, @separator)

  def to_string(scopes) when is_list(scopes),
    do: Enum.join(scopes, " ")

  def can_upload?(scope) when is_list(scope), do: Enum.member?(scope, "media")
end
