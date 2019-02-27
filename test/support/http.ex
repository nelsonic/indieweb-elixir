defmodule IndieWeb.Test.HttpAdapter do
  defdelegate request(uri, methods, opts), to: IndieWeb.Http.Adapters.HTTPotion
end
