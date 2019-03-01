use Mix.Config

config :indieweb,
  webmention_url_adapter: IndieWeb.Test.WebmentionUrlAdapter

config :logger, level: :debug

config :exvcr,
  vcr_cassette_library_dir: "test/fixtures/vcr_cassettes",
  custom_cassette_library_dir: "test/fixtures/custom_cassettes",
  filter_sensitive_data: [
    [pattern: "<PASSWORD>.+</PASSWORD>", placeholder: "PASSWORD_PLACEHOLDER"]
  ],
  filter_url_params: false,
  filter_request_headers: [],
  response_headers_blacklist: []
