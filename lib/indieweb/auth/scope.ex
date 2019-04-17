defmodule IndieWeb.Auth.Scope do
  @moduledoc """
  Handles scope information and referencing for the IndieAuth flow.
  """
  @separator " "

  @spec persist!(binary(), binary()) :: :ok
  def persist!(code, scope)
  def persist!(code, ""), do: persist!(code, "read")

  def persist!(code, scope) when is_list(scope),
    do: persist!(code, __MODULE__.to_string(scope))

  def persist!(code, scope) do
    IndieWeb.Auth.adapter().scope_persist(code, scope)
  end

  @spec get(binary()) :: binary() | nil
  def get(code) do
    case IndieWeb.Auth.adapter().scope_get(code) do
      scope when not is_nil(scope) -> scope |> from_string
      _ -> nil
    end
  end

  def from_string(scope_string) when is_binary(scope_string),
    do: String.split(scope_string, @separator, trim: true)

  def to_string(scopes) when is_list(scopes),
    do: Enum.join(scopes, @separator)

  def can_upload?(scope) when is_list(scope), do: Enum.member?(scope, "media")
end
