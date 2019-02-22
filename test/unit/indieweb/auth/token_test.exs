defmodule IndieWeb.Auth.TokenTest do
  use IndieWeb.TestCase, async: false
  alias IndieWeb.Auth.Token, as: Subject
  alias IndieWeb.Test.AuthAdapter, as: TestAdapter

  setup do
    Application.put_env(:indieweb, :auth_adapter, TestAdapter, persistent: true)
  end

  describe ".generate/3" do
    test "generates token for code" do
      assert TestAdapter.token() ==
               Subject.generate(
                 TestAdapter.code(),
                 TestAdapter.client_id(),
                 TestAdapter.redirect_uri()
               )
    end

    test "fails if the URIs don't match the code" do
      assert {:error, :token_generation_failure, reason: :code_mismatch} =
               Subject.generate(
                 TestAdapter.code(),
                 TestAdapter.client_id() <> "_wrong",
                 TestAdapter.redirect_uri()
               )

      assert {:error, :token_generation_failure, reason: :code_mismatch} =
               Subject.generate(
                 TestAdapter.code(),
                 TestAdapter.client_id(),
                 TestAdapter.redirect_uri() <> "_wrong"
               )
    end

    test "fails if code has no scope" do
      assert {:error, :token_generation_failure, reason: :missing_scope} =
               Subject.generate(
                 TestAdapter.code() <> "_no_scope",
                 TestAdapter.client_id(),
                 TestAdapter.redirect_uri()
               )
    end
  end

  describe ".info_for/1" do
    test "successfully fetches info about token" do
      assert %{"me" => TestAdapter.me(), "client_id" => TestAdapter.client_id(), "scope" => "create read"} ==
               Subject.info_for(TestAdapter.token())
    end

    test "fails if token does not point to user" do
      assert {:error, :incorrect_me_for_token} ==
               Subject.info_for(TestAdapter.token() <> "_wrong_user")
    end

    test "fails if token is deemed invalid" do
      assert {:error, :invalid_token} ==
               Subject.info_for(TestAdapter.token() <> "_invalid")
    end
  end

  describe ".revoke/1" do
    test "successfully destroys provided token" do
      assert :ok = Subject.revoke(TestAdapter.token())
    end

    test "passes through for deemed invalid token" do
      assert :ok = Subject.revoke(TestAdapter.token() <> "_invalid")
    end
  end
end
