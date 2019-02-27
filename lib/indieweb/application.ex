defmodule IndieWeb.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Cachex, [:indieweb, []])
    ]

    opts = [strategy: :one_for_one, name: Koype.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
