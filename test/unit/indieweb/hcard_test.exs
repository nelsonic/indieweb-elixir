defmodule IndieWeb.HCardTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.HCard, as: Subject

  @url "https://indieweb.card"
  @hcard %{
    "url" => @url,
    "uid" => @url,
    "photo" => "https://indieweb.card/photo",
    "note" => "This is a note.",
    "name" => "Fake name"
  }

  describe ".fetch_representative/1" do
    test "finds top-level h-card contains a u-uid and u-url" do
      html = """
      <html>
      <body>
      <div class="h-card">
      <img class="u-photo" src="#{@hcard["photo"]}" />
      <a href="#{@url}" class="u-url u-uid">
      <span class="p-name">#{@hcard["name"]}</span>
      </a>
      <p class="p-note">#{@hcard["note"]}</p>
      </div>
      </body>
      </html>
      """

      mf2 = Microformats2.parse(html, @url)
      assert {:ok, @hcard} = Subject.fetch_representative(mf2, @url)
    end

    test "finds h-card where url matches a rel=me path" do
      html = """
      <html>
      <link rel="me" href="#{@hcard["url"]}/relme"
      <body>
      <div class="h-card">
      <img class="u-photo" src="#{@hcard["photo"]}" />
      <a href="#{@url}/relme" class="u-url u-uid">
      <span class="p-name">#{@hcard["name"]}</span>
      </a>
      <p class="p-note">#{@hcard["note"]}</p>
      </div>
      </body>
      </html>
      """

      mf2 = Microformats2.parse(html, @url)

      expected_hcard =
        Map.merge(@hcard, %{
          "url" => @hcard["url"] <> "/relme",
          "uid" => @hcard["url"] <> "/relme"
        })

      assert {:ok, ^expected_hcard} = Subject.fetch_representative(mf2, @url)
    end

    test "finds lone h-card on page" do
      html = """
      <html>
      <body>
      <div class="h-card">
      <img class="u-photo" src="#{@hcard["photo"]}" />
      <a href="#{@url}/lone" class="u-url u-uid">
      <span class="p-name">#{@hcard["name"]}</span>
      </a>
      <p class="p-note">#{@hcard["note"]}</p>
      </div>
      </body>
      </html>
      """

      mf2 = Microformats2.parse(html, @url)

      expected_hcard =
        Map.merge(@hcard, %{
          "url" => @hcard["url"] <> "/lone",
          "uid" => @hcard["url"] <> "/lone"
        })

      assert {:ok, ^expected_hcard} = Subject.fetch_representative(mf2, @url)
    end
  end

  describe ".resolve/1" do
    test "successfully resolves a h-card from the provided URI" do
      use_cassette "hcard_finds_from_homepage" do
        assert {:ok,
                %{
                  "photo" =>
                    "https://jacky.wtf/assets/brand/self-2018-5037f4d6316311e2c53cb78919e29d9a980d032a4a1082686b9b9db3f5fd8621.jpg"
                }} = Subject.resolve("https://jacky.wtf")
      end
    end

    test "successfully resolves a h-card from authorship" do
      use_cassette "hcard_finds_from_authorship" do
        assert {:ok,
                %{
                  "photo" =>
                    "https://jacky.wtf/assets/brand/self-2018-5037f4d6316311e2c53cb78919e29d9a980d032a4a1082686b9b9db3f5fd8621.jpg"
                }} =
                 Subject.resolve("https://jacky.wtf/weblog/wafflejs-jan-2019/")
      end
    end

    test "resolves generic h-card from non-MF2 site" do
      use_cassette "hcard_generate_from_uri" do
        assert {:ok, %{"name" => "firefox.com"}} =
                 Subject.resolve("http://firefox.com")
      end
    end
  end
end
