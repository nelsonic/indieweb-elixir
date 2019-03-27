defmodule IndieWeb.HttpMock do
  defmacro __using__(_) do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
    end
  end
end
