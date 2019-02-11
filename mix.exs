defmodule IndieWeb.MixProject do
  use Mix.Project
  @description "Helpers and facilities for working with the IndieWeb."

  def project do
    [
      app: :elixir,
      version: "0.0.1",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:microformats2, "~> 0.2.0"},
      {:exvcr, "~> 0.10", only: :test},
      {:faker, "~> 0.12.0", only: :test},
    ]
  end

  defp package() do
    [
      name: "indieweb",
      licenses: ["APGL v3.0"],
      links: %{"Source Code" => "https://git.jacky.wtf/indieweb/elixir"}
    ]
  end


  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
