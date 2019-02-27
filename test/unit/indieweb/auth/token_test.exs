defmodule IndieWeb.Auth.TokenTest do
  use IndieWeb.TestCase, async: true
  alias IndieWeb.Auth.Token, as: Subject

  defp setup_code(_) do
    client_id = "https://indieauth.token"
    redirect_url = client_id <> "/redirect"
    scope = "read update create"

    code =
      IndieWeb.Auth.Code.generate(client_id, redirect_url, %{"scope" => scope})

    :ok =
      IndieWeb.Auth.Code.persist(code, client_id, redirect_url, %{
        "scope" => scope
      })

    :ok = IndieWeb.Auth.Scope.persist!(code, scope)

    {:ok,
     code: code, client_id: client_id, redirect_url: redirect_url, scope: scope}
  end

  defp setup_token(%{
         code: code,
         client_id: client_id,
         redirect_url: redirect_url
       }) do
    case Subject.generate(code, client_id, redirect_url) do
      {:ok, token} ->
        {:ok, token: token, me: "https://indieauth.me"}

      error ->
        error
    end
  end

  describe ".generate/3" do
    setup [:setup_code]

    test "generates token for code",
         %{code: code, client_id: client_id, redirect_url: redirect_url} do
      assert Subject.generate(
               code,
               client_id,
               redirect_url
             )
    end

    test "fails if code has no scope",
         %{code: code, client_id: client_id, redirect_url: redirect_url} do
      assert {:error, :token_generation_failure, reason: :missing_scope} =
               Subject.generate(
                 code <> "_no_scope",
                 client_id,
                 redirect_url
               )
    end
  end

  describe ".info_for/1" do
    setup [:setup_code, :setup_token]

    test "successfully fetches info about token", %{
      token: token
    } do
      assert %{"scope" => scope} = Subject.info_for(token)
    end

    test "fails if token not found", %{token: token} do
      assert {:error, :token_not_found} == Subject.info_for(token <> "_invalid")
    end
  end

  describe ".revoke/1" do
    setup [:setup_code, :setup_token]

    test "successfully destroys provided token", %{token: token} do
      assert :ok = Subject.revoke(token)
    end

    test "passes through for deemed invalid token", %{token: token} do
      assert :ok = Subject.revoke(token <> "_invalid")
    end
  end
end
