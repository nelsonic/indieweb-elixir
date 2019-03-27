defmodule IndieWeb.URL do
  def canonalize(url)
  def canonalize(%URI{path: path} = url) when path in [nil, ""], do: canonalize(URI.merge(url, "/"))
  def canonalize(url), do: url

  def resolve_redirect(url) do
    case IndieWeb.Http.get(url) do
      {:ok, %{url: resolved_url}} -> resolved_url
      _ -> url
    end
  end
end
