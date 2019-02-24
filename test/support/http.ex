defmodule IndieWeb.Test.HttpAdapter do
  defdelegate request(uri, methods, opts), to: IndieWeb.Http.Adapters.HTTPotion
end

Application.put_env(:indieweb, :http_adapter, IndieWeb.Test.HttpAdapter,
  persistent: true
)
