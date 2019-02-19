defmodule IndieWeb.Test.WebmentionUrlAdapter do
  @behaviour IndieWeb.Webmention.URIAdapter

  def from_target_url(target_url)
  def from_target_url("https://target.indieweb/fake"), do: :fake_target
  def from_target_url(_), do: nil

  def to_source_url(target_url)
  def to_source_url(:fake_source), do: URI.parse("https://source.indieweb/fake")
  def to_source_url(_), do: :nil
end

Application.put_env(:indieweb, :webmention_url_adapter, IndieWeb.Test.WebmentionUrlAdapter, persistent: true)
