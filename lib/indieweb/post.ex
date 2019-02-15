defmodule IndieWeb.Post do
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

      do_detect_article(properties) == true ->
        :article

      do_detect_note(properties) == true ->
        :note

      true ->
        :note
    end
  end

  @spec extract_types(map()) :: list()
  def extract_types(properties) do
    types =
      properties
      |> Map.keys()
      |> Enum.map(fn
        key when is_binary(key) -> Map.get(@properties_to_kind, key, nil)
        key when is_atom(key) -> Map.get(@properties_to_kind, Atom.to_string(key), nil)
      end)
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
      String.trim(Enum.join(properties["name"])) != "" -> false
      true -> true
    end
  end

  defp do_detect_article(properties) do
    content = properties["content"]["value"]
    name = Map.get(properties, "name") |> Enum.map(&String.trim/1) |> Enum.join(" ")
    List.starts_with?(content, [name])
  end
end
