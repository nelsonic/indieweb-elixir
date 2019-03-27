defmodule IndieWeb.AppTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.App, as: Subject

  @uri "https://fake.uri/for-real"

  describe ".clear/1" do
    test "clears app information from cache" do
      assert :ok = Subject.clear(@uri)
    end
  end

  describe ".retrieve/1" do
    test "fails to find a suitable parser" do
      use_cassette :stub, uri: @uri, body: "<html></html>" do
        assert {:error, :no_compatible_parsers} = Subject.retrieve(@uri)
      end
    end

    test "fails to fetch info from parser" do
      use_cassette :stub, uri: @uri, body: "" do
        assert {:error, :no_compatible_parsers} = Subject.retrieve(@uri)
      end
    end

    test "fetches info from a parser" do
      use_cassette "app_fetch_from_quill" do
        assert {:ok,
                %{
                  "name" => "Quill",
                  "url" => "https://quill.p3k.io/",
                  "logo" => "https://quill.p3k.io/images/quill-logo-144.png"
                }} = Subject.retrieve("https://quill.p3k.io")
      end

      use_cassette "app_fetch_from_jackys_site" do
        assert {:ok, %{"name" => "jacky.wtf"}} =
                 Subject.retrieve("https://jacky.wtf")
      end
    end
  end
end
