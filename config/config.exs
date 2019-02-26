use Mix.Config

config :indieweb,
  http_adapter: IndieWeb.Http.Adapters.HTTPotion,
  cache_adapter: IndieWeb.Cache.Adapters.Cachex,
  auth_adapter: IndieWeb.Auth.Adapters.Default

import_config "#{Mix.env()}.exs"
