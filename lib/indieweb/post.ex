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

      do_detect_note(properties) == true ->
        :note

      do_detect_article(properties) == true ->
        :article

      true ->
        :note
    end
  end

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
      Enum.map(property_names,&(Map.get(@properties_to_kind, &1, nil)))
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

  defp do_detect_article(properties) do
    content = cond do
      properties["content"]["value"] != [] -> properties["content"]["value"]
      properties["summary"]["value"] != [] -> properties["summary"]["value"]
    end

    name = Map.get(properties, "name", []) |> Enum.map(&String.trim/1) |> Enum.join(" ")
    !List.starts_with?(content, [name]) and name != ""
  end
end
