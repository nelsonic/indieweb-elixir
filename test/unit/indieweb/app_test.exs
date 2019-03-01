defmodule IndieWeb.AppTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.App, as: Subject

  @uri Faker.Internet.url()

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
        assert {:ok, _} = Subject.retrieve("https://quill.p3k.io")
      end
    end
  end
end
