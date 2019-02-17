defmodule IndieWeb.PostTest do
  use IndieWeb.TestCase, async: true
  alias IndieWeb.Post, as: Subject
  doctest Subject

  describe ".extract_types/1" do
    test "detects a note type" do
      assert [:note] = Subject.extract_types(%{"content" => %{"value" => ""}})
    end

    test "detects a rsvp" do
      assert [:rsvp] = Subject.extract_types(%{"rsvp" => ["yes"], "content" => %{"value" => ""}})
    end

    test "detects a reply" do
      assert [:reply] =
               Subject.extract_types(%{
                 "in-reply-to" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })

      assert [:reply] =
               Subject.extract_types(%{
                 "in_reply_to" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })
    end

    test "detects a like" do
      assert [:like] =
               Subject.extract_types(%{
                 "like_of" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })

      assert [:like] =
               Subject.extract_types(%{
                 "like-of" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })
    end

    test "detects a bookmark" do
      assert [:bookmark] =
               Subject.extract_types(%{
                 "bookmark_of" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })

      assert [:bookmark] =
               Subject.extract_types(%{
                 "bookmark-of" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })
    end

    test "detects an event" do
      assert [:event] =
               Subject.extract_types(%{
                 "start" => [DateTime.utc_now()],
                 "end" => [DateTime.utc_now()],
                 "title" => [],
                 "content" => %{"value" => ""}
               })
    end

    test "detects a repost" do
      assert [:repost] =
               Subject.extract_types(%{
                 "repost_of" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })

      assert [:repost] =
               Subject.extract_types(%{
                 "repost-of" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })
    end

    test "detects a check-in" do
      assert [:checkin] =
               Subject.extract_types(%{
                 "checkin" => [
                   %{
                     "items" => %{
                       "prop" => "value"
                     },
                     "type" => ["h-card"]
                   }
                 ],
                 "content" => %{"value" => ""}
               })
    end

    test "detects a photo" do
      assert [:photo] =
               Subject.extract_types(%{
                 "photo" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })
    end

    test "detects a video" do
      assert [:video] =
               Subject.extract_types(%{
                 "video" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })
    end

    test "detects an audio" do
      assert [:audio] =
               Subject.extract_types(%{
                 "audio" => ["https://indieweb.org"],
                 "content" => %{"value" => ""}
               })
    end
  end

  describe ".determine_type/2" do
    test "determines an article type" do
      assert :article =
               Subject.determine_type(
                 %{
                   "content" => %{
                     "value" => ["Content value."],
                     "html" => ["<p>Content value.</p>"]
                   },
                   "name" => ["IndieWeb under your terms."]
                 },
                 [:note, :article]
               )
    end

    test "determines a note" do
      assert :note =
               Subject.determine_type(
                 %{
                   "content" => %{"value" => ["Content value."]}
                 },
                 [:note, :article]
               )
    end
  end

  describe ".is_response_type?/1" do
    test "determines valid post types" do
      assert Subject.is_response_type?(:reply)
      assert Subject.is_response_type?(:repost)
      assert Subject.is_response_type?(:like)
      refute Subject.is_response_type?(:note)
      refute Subject.is_response_type?(:article)
    end
  end
end
