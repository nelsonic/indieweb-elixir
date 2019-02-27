defmodule IndieWeb.Test.WebmentionUrlAdapter do
  @behaviour IndieWeb.Webmention.URIAdapter

  def from_source_url(target_url)
  def from_source_url("https://target.indieweb/fake"), do: :fake_source
  def from_source_url(_), do: nil

  def to_source_url(target_url)
  def to_source_url(:fake_source), do: URI.parse("https://source.indieweb/fake")
  def to_source_url(_), do: nil
end
