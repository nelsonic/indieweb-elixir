defmodule IndieWeb.WebmentionTest do
  use IndieWeb.TestCase, async: false
  use IndieWeb.HttpMock
  alias IndieWeb.Webmention, as: Subject

  setup do
    Application.put_env(
      :indieweb,
      :webmention_url_adapter,
      IndieWeb.Test.WebmentionUrlAdapter,
      persistent: true
    )
  end

  describe ".discover_endpoint/1" do
    test "HTTP Link header, unquoted rel, relative URL" do
      use_cassette "webmention_test_header_unquoted_relative" do
        assert {:ok, "https://webmention.rocks/test/1/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/1"
                 )
      end
    end

    test "HTTP Link header, unquoted rel, absolute URL" do
      use_cassette "webmention_test_header_unquoted_absolute" do
        assert {:ok, "https://webmention.rocks/test/2/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/2"
                 )
      end
    end

    test "HTML <link> tag, relative URL" do
      use_cassette "webmention_test_tag_link_relative" do
        assert {:ok, "https://webmention.rocks/test/3/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/3"
                 )
      end
    end

    test "HTML <link> tag, absolute URL" do
      use_cassette "webmention_test_tag_link_absolute" do
        assert {:ok, "https://webmention.rocks/test/4/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/4"
                 )
      end
    end

    test "HTML <a> tag, relative URL" do
      use_cassette "webmention_test_tag_a_relative" do
        assert {:ok, "https://webmention.rocks/test/5/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/5"
                 )
      end
    end

    test "HTML <a> tag, absolute URL" do
      use_cassette "webmention_test_tag_a_absolute" do
        assert {:ok, "https://webmention.rocks/test/6/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/6"
                 )
      end
    end

    test "HTTP Link header with strange casing" do
      use_cassette "webmention_test_header_strange_casing" do
        assert {:ok, "https://webmention.rocks/test/7/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/7"
                 )
      end
    end

    test "HTTP Link header, quoted rel" do
      use_cassette "webmention_test_header_quoted_rel" do
        assert {:ok, "https://webmention.rocks/test/8/webmention"} =
                 IndieWeb.Webmention.discover_endpoint(
                   "https://webmention.rocks/test/8"
                 )
      end
    end

    test "Multiple rel values on a <link> tag" do
      use_cassette "webmention_test_tag_link_multiple_values" do
        assert {:ok, "https://webmention.rocks/test/9/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/9")
      end
    end

    test "Multiple rel values on a Link header" do
      use_cassette "webmention_test_header_link_multiple_values" do
        assert {:ok, "https://webmention.rocks/test/10/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/10")
      end
    end

    test "Multiple Webmention endpoints advertised: Link, <link>, <a>" do
      use_cassette "webmention_test_multiple_endpoints" do
        assert {:ok, "https://webmention.rocks/test/11/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/11")
      end
    end

    test "Checking for exact match of rel=webmention" do
      use_cassette "webmention_test_testing_rel_matching" do
        assert {:ok, "https://webmention.rocks/test/12/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/12")
      end
    end

    test "False endpoint inside an HTML comment" do
      use_cassette "webmention_test_false_endpoint_comment" do
        assert {:ok, "https://webmention.rocks/test/13/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/13")
      end
    end

    test "False endpoint in escaped HTML" do
      use_cassette "webmention_test_false_endpoint_escaped" do
        assert {:ok, "https://webmention.rocks/test/14/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/14")
      end
    end

    @tag skip: true
    test "Webmention href is an empty string" do
      use_cassette "webmention_test_href_is_empty_string" do
        assert {:ok, "https://webmention.rocks/test/15/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/15")
      end
    end

    test "Multiple Webmention endpoints advertised: <a>, <link>" do
      use_cassette "webmention_test_multiple_endpoints_tags_link" do
        assert {:ok, "https://webmention.rocks/test/16/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/16")
      end
    end

    test "Multiple Webmention endpoints advertised: <link>, <a>" do
      use_cassette "webmention_test_multiple_endpoints_tags_a" do
        assert {:ok, "https://webmention.rocks/test/17/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/17")
      end
    end

    @tag skip: true
    test "Multiple HTTP Link headers" do
      use_cassette "webmention_test_multiple_header_values" do
        assert {:ok, "https://webmention.rocks/test/18/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/18")
      end
    end

    test "Single HTTP Link header with multiple values" do
      use_cassette "webmention_test_single_header_multiple_values" do
        assert {:ok, "https://webmention.rocks/test/19/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/19")
      end
    end

    test "Link tag with no href attribute" do
      use_cassette "webmention_test_skip_link_with_no_href" do
        assert {:ok, "https://webmention.rocks/test/20/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/20")
      end
    end

    test "Webmention endpoint has query string parameters" do
      use_cassette "webmention_test_keep_query_params" do
        assert {:ok, "https://webmention.rocks/test/21/webmention?query=yes"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/21")
      end
    end

    test "Webmention endpoint is relative to the path" do
      use_cassette "webmention_test_path_relative_to_uri" do
        assert {:ok, "https://webmention.rocks/test/22/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/22")
      end
    end

    @tag skip: true
    test "Webmention target is a redirect and the endpoint is relative" do
      use_cassette "webmention_test_path_relative_redirect" do
        assert {:ok, "https://webmention.rocks/test/23/webmention"} =
                 Subject.discover_endpoint("https://webmention.rocks/test/23")
      end
    end
  end

  describe ".send/3" do
    test "successfully sends a Webmention" do
      use_cassette "webmention_send_success" do
        assert {:ok, send_resp} =
                 Subject.send("https://webmention.target/page", :fake_source)

        assert %{code: 201} = send_resp
      end
    end

    test "fails if server reports error" do
      use_cassette "webmention_send_failure" do
        assert {:error, :webmention_send_failure, _} =
                 Subject.send("https://webmention.target/page", :fake_source)
      end
    end

    test "fails if source URI could be obtained" do
      assert {:error, :webmention_send_failure, reason: :no_endpoint_found} =
               Subject.send("https://webmention.target/page", :bad_test_source)
    end

    test "fails if no Webmention endpoint was found for target" do
      assert {:error, :webmention_send_failure, reason: :no_endpoint_found} =
               Subject.send(
                 "https://webmention.target/page?no=endpoint",
                 :fake_source
               )
    end
  end

  describe ".receive/1" do
    test "successfully receives a Webmention" do
      assert {:ok, resp} =
               Subject.receive(
                 source: "https://webmention.target/source",
                 target: "https://target.indieweb/fake"
               )

      assert [
               source: "https://webmention.target/source",
               target: :fake_source,
               target_url: "https://target.indieweb/fake"
             ] = resp
    end

    test "fails if target URI does not resolve to anything" do
      assert {:error, :webmention_receive_failure, reason: :no_target} =
               Subject.receive(
                 source: "https://webmention.target/source",
                 target: "https://target.indieweb/goes/nowhere"
               )
    end
  end

  describe ".resolve_target_from_url/1" do
    test "generates URI for provided object" do
      assert {:ok, :fake_source} =
               Subject.resolve_target_from_url("https://target.indieweb/fake")
    end

    test "fails if no adapter is set" do
      Application.delete_env(:indieweb, :webmention_url_adapter)

      assert {:error, :no_adapter} =
               Subject.resolve_target_from_url("https://target.indieweb/fake")
    end

    test "fails if adapter returns nil" do
      assert {:error, :no_target} =
               Subject.resolve_target_from_url("https://target.indieweb/nil")
    end
  end

  describe ".resolve_source_url/1" do
    test "obtains object from URI" do
      uri = URI.parse("https://source.indieweb/fake")
      assert {:ok, ^uri} = Subject.resolve_source_url(:fake_source)
    end

    test "fails if no adapter is set" do
      Application.delete_env(:indieweb, :webmention_url_adapter)
      assert {:error, :no_adapter} = Subject.resolve_source_url(:fake_source)
    end

    test "fails if adapter returns nil" do
      assert {:error, :no_source} = Subject.resolve_source_url(:no_source)
    end
  end
end
