defmodule IndieWeb.Auth do
  @moduledoc """
  Provides basic logic for handling [IndieAuth](https://indieauth.spec.indieweb.org) interactions.
  """

  @doc "Provides endpoint information for well known endpoints in IndieAuth."
  @spec endpoint_for(atom(), binary()) :: binary() | nil
  def endpoint_for(type, uri)

  def endpoint_for(component, url) when component in ~w(authorization token)a do
    IndieWeb.LinkRel.find(url, "#{component}_endpoint") |> List.first
  end
  def endpoint_for(:redirect_url, url), do: IndieWeb.LinkRel.find(url, "redirect_url")
  def endpoint_for(_, _), do: nil
end
