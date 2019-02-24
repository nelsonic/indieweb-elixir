defmodule IndieWeb.HCard do
  @moduledoc """
  Extracts the representative [h-card](http://indieweb.org/h-card) of the provided URI.
  """

  @doc """
  Obtains a remote page and determines the h-card of the current page.

  This takes a few approaches to find a h-card for the page in question.
  It'll first search for a top-level h-card on the page.
  If there isn't an obvious one, it'll search for a representative h-card.
  """
  def resolve(uri) when is_binary(uri) do
    %{scheme: scheme, authority: authority} =
      URI.parse(uri |> String.trim_trailing("/"))

    host = "#{scheme}://#{authority}"

    approaches = [
      fn ->
        case fetch_representative(uri) do
          {:ok, hcard} -> hcard
          _ -> nil
        end
      end,
      fn ->
        with(
          {:ok, %IndieWeb.Http.Response{body: body}} <- IndieWeb.Http.get(uri),
          mf2 when is_map(mf2) <- Microformats2.parse(body, uri),
          {:ok, hcard} <- do_check_author_of_first_entry(mf2, {host, uri})
        ) do
          hcard
        else
          _ ->
            nil
        end
      end,
      fn ->
        do_format_hcard(do_stub_out_hcard(uri), host)
      end
    ]

    result = Enum.find_value(approaches, & &1.())

    case result do
      nil -> {:error, :no_hcard_found}
      formatted_hcard -> {:ok, formatted_hcard}
    end
  end

  def resolve(mf2, uri) when is_map(mf2) do
    %{scheme: scheme, authority: authority} =
      URI.parse(uri |> String.trim_trailing("/"))

    host = "#{scheme}://#{authority}"

    case fetch_representative(mf2, {host, uri}) do
      {:ok, hcard} -> hcard
      _ -> nil
    end
  end

  @doc """
  Obtains the representative h-card of the provided URI.

  The [steps for parsing a representative h-card][1] are as follows:

  * If the page contains an `h-card` with `uid` and `url` properties
  both matching the page URL, the first such `h-card` is the
  **representative h-card**.
  * If no representative h-card was found, if the page contains an
  `h-card` with a url property value which also has a rel=me
  relation, the first such `h-card` is the **representative h-card**
  * If no representative `h-card` was found, if the page contains one
  single `h-card`, and the `h-card` has a url property matching the
  page URL, that `h-card` is the representative `h-card`
  * <thunk>

  [1]: http://microformats.org/wiki/representative-h-card-parsing
  """
  def fetch_representative(uri) when is_binary(uri) do
    with(
      {:ok, %IndieWeb.Http.Response{body: body}} <- IndieWeb.Http.get(uri),
      mf2 when is_map(mf2) <- Microformats2.parse(body, uri),
      {:ok, hcard} <- fetch_representative(mf2, uri)
    ) do
      {:ok, hcard}
    else
      _ -> nil
    end
  end

  def fetch_representative(mf2, uri) do
    %{scheme: scheme, authority: authority} =
      URI.parse(uri |> String.trim_trailing("/"))

    root_uri = "#{scheme}://#{authority}"

    approaches = [
      &do_find_uid_url/2,
      &do_find_with_matching_relme/2,
      &do_find_solo/2
    ]

    Enum.reduce_while(approaches, {:error, :no_hcard_found}, fn approach, acc ->
      case approach.(mf2, {root_uri, uri}) do
        nil ->
          {:cont, acc}

        hcard when is_map(hcard) ->
          {:halt, {:ok, do_format_hcard(hcard, root_uri)}}
      end
    end)
  end

  # TODO: We search rel=author and rel=home as well in hopes of expanding those
  # for whose have might MicroFormats2 support but not fully.
  defp do_find_with_matching_relme(mf2, {host, _}) do
    rel_mes =
      ~w(home me author)
      |> Enum.map(fn key -> Map.get(mf2, :rels, %{}) |> Map.get(key, []) end)
      |> List.flatten()
      |> Enum.map(&String.trim_trailing(&1, "/"))
      |> Enum.map(&URI.parse/1)
      |> Enum.map(&URI.to_string/1)

    cards = Microformats2.Utility.extract_all(mf2, "card")

    Enum.find_value(cards, fn hcard ->
      urls = Microformats2.Utility.get_value(hcard, :url, [])

      Enum.find_value(urls, fn current_url ->
        hcard_uri =
          IndieWeb.Http.make_absolute_uri(current_url, host)
          |> String.trim_trailing("/")
          |> URI.parse()
          |> URI.to_string()

        if Enum.member?(rel_mes, hcard_uri) do
          hcard
        else
          nil
        end
      end)
    end)
  end

  # TODO: We can have multiple UIDs as well - maybe tuple setup.
  defp do_find_uid_url(mf2, {_, uri}) do
    cards = Microformats2.Utility.extract_all(mf2, "card")

    Enum.find_value(cards, fn hcard ->
      hcard_uri =
        Microformats2.Utility.get_value(hcard, :url, ["/"])
        |> List.first()
        |> String.trim_trailing("/")

      hcard_uid =
        Microformats2.Utility.get_value(hcard, :uid, []) |> List.first()

      valid_uid =
        if is_nil(hcard_uid) do
          true
        else
          String.trim_trailing(hcard_uid, "/") == uri
        end

      if hcard_uri == uri && valid_uid do
        hcard
      else
        nil
      end
    end)
  end

  defp do_check_author_of_first_entry(mf2, {host, _}) do
    top_items =
      mf2[:items]
      |> Enum.reject(fn item -> Enum.member?(item["type"], "h-card") end)

    Enum.find_value(top_items, fn item ->
      authors = Microformats2.Utility.get_value(item, "author")

      Enum.find_value(authors, fn
        author_map when is_map(author_map) ->
          {:ok, do_format_hcard(author_map, host)}

        author_uri when is_binary(author_uri) ->
          resolved_author_uri =
            IndieWeb.Http.make_absolute_uri(author_uri, host)

          case IndieWeb.HCard.resolve(resolved_author_uri) do
            {:ok, _} = result -> result
          end
      end)
    end)
  end

  defp do_find_solo(mf2, _) do
    mf2
    |> Map.get(:items, [])
    |> Enum.filter(fn item ->
      Enum.member?(Map.get(item, :type, []), "h-card")
    end)
    |> List.first()
  end

  # TODO: Use JF2 instead of this simplified content.
  defp do_format_hcard(hcard, host) do
    url =
      IndieWeb.Http.make_absolute_uri(
        Microformats2.Utility.get_value(hcard, :url, ["/"]) |> List.first(),
        host
      )

    ~w(name nickname note email label)
    |> Enum.map(fn prop ->
      {prop,
       Microformats2.Utility.get_value(hcard, String.to_atom(prop), [])
       |> List.first()}
    end)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
    |> Map.put(
      "url",
      url
    )
    |> Map.put_new_lazy("uid", fn ->
      uid = Microformats2.Utility.get_value(hcard, :uid, []) |> List.first()

      if is_nil(uid) do
        url
      else
        IndieWeb.Http.make_absolute_uri(uid, host)
      end
    end)
    |> Map.put_new_lazy("photo", fn ->
      photo_uri =
        Microformats2.Utility.get_value(hcard, :photo, []) |> List.first()

      if !is_nil(photo_uri) do
        IndieWeb.Http.make_absolute_uri(photo_uri, host)
      else
        nil
      end
    end)
  end

  defp do_stub_out_hcard(uri) do
    %{
      properties: %{
        name: [URI.parse(uri) |> Map.get(:host)],
        url: [uri],
        uid: [uri]
      },
      type: ["h-card"]
    }
  end
end
