defmodule IndieWeb.Auth.Code do
  @moduledoc """
  Handles authentication codes for the IndieAuth flow.
  """

  @spec generate(binary(), binary(), map()) :: binary()
  def generate(client_id, redirect_uri, data \\ nil) do
    IndieWeb.Auth.adapter().code_generate(client_id, redirect_uri, data)
  end

  @spec persist(binary(), binary(), binary(), map()) :: :ok
  def persist(code, client_id, redirect_uri, args \\ %{}) do
    IndieWeb.Auth.adapter().code_persist(code, client_id, redirect_uri, args)
  end

  @spec verify(binary(), binary(), binary(), map()) :: :ok | {:error, any()}
  def verify(code, client_id, redirect_uri, data \\ %{}) do
    IndieWeb.Auth.adapter().code_verify(code, client_id, redirect_uri, data)
  end

  @spec destroy(binary(), binary(), map()) :: :ok
  def destroy(client_id, redirect_uri, args) do
    IndieWeb.Auth.adapter().code_destroy(client_id, redirect_uri, args)
  end
end
