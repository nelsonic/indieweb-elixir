defmodule IndieWeb.Auth.Code do
  @spec generate(binary(), binary(), map()) :: binary()
  def generate(client_id, redirect_url, data \\ %{}) do
    IndieWeb.Auth.adapter().code_generate(client_id, redirect_url, data)
  end

  @spec persist(binary(), binary(), binary()) :: :ok
  def persist(code, client_id, redirect_url) do
    IndieWeb.Auth.adapter().code_persist(code, client_id, redirect_url)
  end

  @spec verify(binary(), binary(), binary(), map()) :: :ok | {:error, any()}
  def verify(code, client_id, redirect_uri, data \\ %{}) do
    IndieWeb.Auth.adapter().code_verify(code, client_id, redirect_uri, data)
  end

  @spec destroy(binary()) :: :ok
  def destroy(code) do
    IndieWeb.Auth.adapter.code_destroy(code)
  end
end
