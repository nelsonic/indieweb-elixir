defmodule IndieWeb.Auth.CodeTest do
  use IndieWeb.TestCase, async: true
  alias IndieWeb.Auth.Code, as: Subject

  describe ".generate/2" do
    test "provides a new code" do
      assert Subject.generate(
                 "https://indieauth.code",
                 "https://indieauth.code/redirect"
               )

      assert Subject.generate(
        "https://indieauth.code",
        "https://indieauth.code/redirect",
        %{"magic" => "sauce"})
    end
  end

  describe ".persist/3" do
    test "saves the provided code for the client & redirect_uri" do
      assert :ok =
               Subject.persist(
                 "code",
                 "https://indieauth.persist",
                 "https://indieauth.persists/redirect"
               )

      assert :ok =
               Subject.persist(
                 "code",
                 "https://indieauth.persist",
                 "https://indieauth.persists/redirect",
                 %{"scope" => "read update"}
               )
    end
  end

  describe ".verify/3" do
    test "confirms if a code was stored for this value with no data" do
      code = Subject.generate("https://indieauth.code", "https://indieauth.code/foo", %{"grr" => "arg"})
      :ok = Subject.persist(code, "https://indieauth.code", "https://indieauth.code/foo", %{"grr" => "arg"})

      assert :ok =
               Subject.verify(
                 code,
                 "https://indieauth.code",
                 "https://indieauth.code/foo",
                 %{"grr" => "arg"}
               )
    end
  end
end
