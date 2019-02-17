defmodule IndieWeb.WebmentionTest do
  use IndieWeb.TestCase, async: false
  use ExVCR.Mock
  alias IndieWeb.Webmention, as: Subject

  setup do
    Application.put_env(:indieweb, :http_adapter, IndieWeb.Test.HttpAdapter, persistent: true)
    :ok
  end

  describe ".discover_endpoint/1" do
    test "HTTP Link header, unquoted rel, relative URL" do
      use_cassette "webmention_test_header_unquoted_relative" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/1")
      end
    end

    test "HTTP Link header, unquoted rel, absolute URL" do
      use_cassette "webmention_test_header_unquoted_absolute" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/2")
      end
    end

    test "HTML <link> tag, relative URL" do
      use_cassette "webmention_test_tag_link_relative" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/3")
      end
    end

    test "HTML <link> tag, absolute URL" do
      use_cassette "webmention_test_tag_link_absolute" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/4")
      end
    end

    test "HTML <a> tag, relative URL" do
      use_cassette "webmention_test_tag_a_relative" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/5")
      end
    end

    test "HTML <a> tag, absolute URL" do
      use_cassette "webmention_test_tag_a_absolute" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/6")
      end
    end

    test "HTTP Link header with strange casing" do
      use_cassette "webmention_test_header_strange_casing" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/7")
      end
    end

    test "HTTP Link header, quoted rel" do
      use_cassette "webmention_test_header_quoted_rel" do
        assert {:ok, ""} =
                 IndieWeb.Webmention.discover_endpoint("https://webmention.rocks/test/8")
      end
    end

    test "Multiple rel values on a <link> tag" do
      use_cassette "webmention_test_tag_link_multiple_values" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/9")
      end
    end

    test "Multiple rel values on a Link header" do
      use_cassette "webmention_test_header_link_multiple_values" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/10")
      end
    end

    test "Multiple Webmention endpoints advertised: Link, <link>, <a>" do
      use_cassette "webmention_test_multiple_endpoints" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/11")
      end
    end

    test "Checking for exact match of rel=webmention" do
      use_cassette "webmention_test_testing_rel_matching" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/12")
      end
    end

    test "False endpoint inside an HTML comment" do
      use_cassette "webmention_test_false_endpoint_comment" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/13")
      end
    end

    test "False endpoint in escaped HTML" do
      use_cassette "webmention_test_false_endpoint_escaped" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/14")
      end
    end

    test "Webmention href is an empty string" do
      use_cassette "webmention_test_href_is_empty_string" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/15")
      end
    end

    test "Multiple Webmention endpoints advertised: <a>, <link>" do
      use_cassette "webmention_test_multiple_endpoints_tags_link" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/16")
      end
    end

    test "Multiple Webmention endpoints advertised: <link>, <a>" do
      use_cassette "webmention_test_multiple_endpoints_tags_a" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/17")
      end
    end

    test "Multiple HTTP Link headers" do
      use_cassette "webmention_test_multiple_header_values" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/18")
      end
    end

    test "Single HTTP Link header with multiple values" do
      use_cassette "webmention_test_single_header_multiple_values" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/19")
      end
    end

    test "Link tag with no href attribute" do
      use_cassette "webmention_test_skip_link_with_no_href" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/20")
      end
    end

    test "Webmention endpoint has query string parameters" do
      use_cassette "webmention_test_keep_query_params" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/21")
      end
    end

    test "Webmention endpoint is relative to the path" do
      use_cassette "webmention_test_path_relative_to_uri" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/22")
      end
    end

    test "Webmention target is a redirect and the endpoint is relative" do
      use_cassette "" do
        assert {:ok, ""} = Subject.discover_endpoint("https://webmention.rocks/test/23")
      end
    end
  end
end
