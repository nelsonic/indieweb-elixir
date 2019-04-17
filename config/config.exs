use Mix.Config

config :indieweb,
  cache_adapter: IndieWeb.Cache.Adapters.Cachex,
  auth_adapter: IndieWeb.Auth.Adapters.Default

config :tesla, :adapter, Tesla.Adapter.Hackney

config :mnesia, dir: 'priv/mnesia/#{Mix.env()}/#{node()}'

import_config "#{Mix.env()}.exs"
