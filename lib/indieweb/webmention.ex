defmodule IndieWeb.Webmention do
  @moduledoc """
  Handles Webmention interoperability for a site.
  """

  @doc """
  Finds the Webmention endpoint of the provided URI.

  This employs the [Webmention endpoint discovery algorithm][1] to find
  the proper endpoint to send Webmentions for the URI in question.
  
  [1]: https://www.w3.org/TR/webmention/#sender-discovers-receiver-webmention-endpoint
  """
  @spec discover_endpoint(binary) :: {:ok, binary()} | {:error, any()}
  def discover_endpoint(uri) do

  end
end
