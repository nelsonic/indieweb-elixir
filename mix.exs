defmodule IndieWeb.MixProject do
  use Mix.Project
  @description "Helpers and facilities for working with the IndieWeb."

  def project do
    [
      app: :elixir,
      version: "0.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: @description,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      {:microformats2, "~> 0.2.0"}
    ]
  end

  defp package() do
    [
      name: "indieweb",
      licenses: ["APGL v3.0"],
      links: %{"Source Code" => "https://git.jacky.wtf/indieweb/elixir"}
    ]
  end
end
