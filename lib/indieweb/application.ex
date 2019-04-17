defmodule IndieWeb.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Cachex, [:indieweb, [limit: 100]])
    ]

    opts = [strategy: :one_for_one, name: IndieWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
