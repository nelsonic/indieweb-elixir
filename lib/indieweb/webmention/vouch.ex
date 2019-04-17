defmodule IndieWeb.Webmention.Vouch do
  def valid?(vouch, remote_url) do
    # TODO: Fetch MF2 of page at 'vouch'.
    # TODO: Get re h-card of 'remote_url'.
    with(
      {:ok, mf2} <- Microformats2.Utility.fetch(vouch),
      {:ok, hcard} <- IndieWeb.HCard.resolve(remote_url)
    ) do
      hcards = Microformats2.Utility.extract_deep(mf2, "card")
    end
  end
end
