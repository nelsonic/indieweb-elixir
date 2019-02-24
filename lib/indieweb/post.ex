defmodule IndieWeb.Post do
  @moduledoc """
  Post-specific logic for the IndieWeb.

  This module provides helper methods for parsing [MF2](http://microformats.org/wiki/microformats2-parsing)
  data in a handy and simple fashion. The structure of the properties you'd use would be similar
  to that of a <abbr tittle="Micformats2 JSON">MF2+JSON</abbr> object:

  ```json
  {
    "items": [
        {
            "type": [
                "h-feed"
            ],
            "properties": {
                "name": [
                    "Updates"
                ],
                "uid": [
                    "https://v2.jacky.wtf/stream"
                ],
                "url": [
                    "https://v2.jacky.wtf/stream"
                ]
            },
            "lang": "en",
            "children": [
                {
                    "type": [
                        "h-entry"
                    ],
                    "properties": {
                        "summary": [
                            "One big step for Koype is going to be bridging the IndieWeb into the IPFS landscape. I have concerns over it not being privacy-centric since there\u2019s no sense of private data (everything is publishable outwards). IPFS provides pubsub logic so I thi..."
                        ],
                        "url": [
                            "https://v2.jacky.wtf/post/4fbdcd28-b558-42bc-99a9-802e33d01810",
                            "https://v2.jacky.wtf/tag/7c1e5ef9-aa31-40e6-b26a-ecdba728b4a1",
                            "https://v2.jacky.wtf/tag/bc945dde-95bb-468e-9127-620f1c35cd70"
                        ],
                        "uid": [
                            "https://v2.jacky.wtf/post/4fbdcd28-b558-42bc-99a9-802e33d01810"
                        ],
                        "category": [
                            "https://v2.jacky.wtf/tag/7c1e5ef9-aa31-40e6-b26a-ecdba728b4a1",
                            "https://v2.jacky.wtf/tag/bc945dde-95bb-468e-9127-620f1c35cd70"
                        ],
                        "published": [
                            "2019-02-15T13:29:51.60956-08:00"
                        ]
                    },
                    "lang": "en"
                }
            ]
        },
        {
            "type": [
                "h-card"
            ],
            "properties": {
                "name": [
                    "Jacky Alcine"
                ],
                "tz": [
                    "America/Los_Angeles"
                ],
                "note": [
                    "I had a dream I could buy my way into heaven. When I woke up, I spent that on a m4.large from EvilCorp. Wait until I get my money right!"
                ],
                "url": [
                    "https://v2.jacky.wtf"
                ],
                "photo": [
                    "https://v2.jacky.wtf/media/image/floating/PhotoJacky%20n%203J5430.png?v=original"
                ]
            },
            "lang": "en"
        }
    ]
  }
  ```
  """

  @doc "Returns a list of atoms representing response post types."
  @spec response_types() :: list(atom)
  def response_types, do: ~w(reply like bookmark repost read rsvp)a

  @doc """
  Determines if the provided type is a response type.

  ## Examples

      iex> IndieWeb.Post.is_response_type?(:note)
      false

      iex> IndieWeb.Post.is_response_type?(:rsvp)
      true
  """
  @spec is_response_type?(binary()) :: boolean()
  def is_response_type?(type) do
    Enum.member?(response_types(), type)
  end

  @properties_to_kind %{
    "checkin" => :checkin,
    "audio" => :audio,
    "in-reply-to" => :reply,
    "in_reply_to" => :reply,
    "like-of" => :like,
    "like_of" => :like,
    "bookmark-of" => :bookmark,
    "bookmark_of" => :bookmark,
    "photo" => :photo,
    "repost-of" => :repost,
    "repost_of" => :repost,
    "rsvp" => :rsvp,
    "video" => :video,
    "start" => :event,
    "name" => :article
  }

  @doc """
  Determines the type of a post from a set of types and its MF2 properties.

  This aims to apply the [Post Type Discovery](http://ptd.spec.indieweb.org/) algorithm for discovering
  what kind of post these properties result in.

  ## Examples


      iex> IndieWeb.Post.determine_type(%{"content" => ["Foo."], "name" => ["Foo."]}, ~w(note article)a)
      :article

      iex> IndieWeb.Post.determine_type(%{"content" => %{"value" => ["Foo."]}, "name" => ["On Bar"]}, ~w(note article)a)
      :article

      iex> IndieWeb.Post.determine_type(%{"content" => %{"value" => ["Foo."]}, "photo" => ["https://magic/jpeg"]}, ~w(note photo)a)
      :photo


  """
  @doc since:
         "http://ptd.spec.indieweb.org/#changes-from-28-october-2016-wd-to-1-march-2017-wd"
  @spec determine_type(map(), list()) :: atom()
  def determine_type(properties, types) do
    cond do
      :event in types ->
        :event

      :rsvp in types ->
        :rsvp

      :reply in types ->
        :reply

      :checkin in types ->
        :checkin

      :repost in types ->
        :repost

      :bookmark in types ->
        :bookmark

      :like in types ->
        :like

      :photo in types ->
        :photo

      :video in types ->
        :video

      do_detect_note(properties) == true ->
        :note

      do_detect_article(properties) == true ->
        :article

      true ->
        :note
    end
  end

  @doc """
  Determines the potential types exposed by the set of provided properties.

  The provided properties are scanned and checked to determine if a particular
  post type can be determined. The matching is a direct property to type mapping.
  You should use `determine_type/2` to resolve the _actual_ post type.

  ## Examples

      iex> IndieWeb.Post.extract_types(%{"photo" => ["https://magic/jpeg"]})
      [:photo]

      iex> IndieWeb.Post.extract_types(%{"content" => %{"value" => ["Just a note."]}})
      [:note]

      iex> IndieWeb.Post.extract_types(%{"content" => %{"value" => ["A whole blog post."]}, "name" => ["Magic."]})
      [:article]
  """
  @spec extract_types(map()) :: list()
  def extract_types(properties) do
    property_names =
      properties
      |> Map.keys()
      |> Enum.map(fn
        key when is_binary(key) -> key
        key -> to_string(key)
      end)

    types =
      property_names
      |> Enum.map(&Map.get(@properties_to_kind, &1, nil))
      |> Enum.reject(&is_nil/1)

    if types == [] do
      [:note]
    else
      types
    end
  end

  defp do_detect_note(properties) do
    cond do
      Map.has_key?(properties, "name") == true -> false
      String.trim(Enum.join(Map.get(properties, "name", []))) != "" -> false
      true -> true
    end
  end

  defp do_flatten_content(content)
  defp do_flatten_content([]), do: []
  defp do_flatten_content(content) when is_list(content), do: content
  defp do_flatten_content(content) when is_binary(content), do: [content]
  defp do_flatten_content(%{"value" => value}) when is_list(value), do: value
  defp do_flatten_content(%{"value" => value}) when is_binary(value), do: [value]

  defp do_detect_article(properties) do
    summary = do_flatten_content(Map.get(properties, "summary", []))
    content = do_flatten_content(Map.get(properties, "content", []))

    name =
      properties
      |> Map.get("name", [])
      |> Enum.map(&String.trim/1)
      |> Enum.join(" ")

    is_binary(name) && name != "" && !List.starts_with?(summary || content, [name])
  end
end
