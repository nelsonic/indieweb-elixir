defmodule IndieWeb.MixProject do
  use Mix.Project
  @description "Helpers and facilities for working with the IndieWeb."

  def project do
    [
      aliases: aliases(),
      app: :indieweb,
      name: "IndieWeb",
      version: "0.0.38",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      description: @description,
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        ci: :test,
        test: :test,
        "coveralls.detail": :test
      ],
      deps: deps(),
      homepage_url: "https://indieweb.org/",
      docs: [
        source_url: "https://git.jacky.wtf/indieweb/elixir",
        source_url_pattern: "https://git.jacky.wtf/indieweb/elixir/src/branch/master/%{path}#L%{line}",
        logo: "priv/static/images/logo.png",
        extras: Path.wildcard("docs/*.markdown")
      ]
    ]
  end

  def application do
    [
      mod: {IndieWeb.Application, []},
      extra_applications: [:logger, :cachex, :runtime_tools, :httpotion]
    ]
  end

  defp deps do
    [
      {:apex, "~> 1.2.1", only: [:dev, :test]},
      {:cachex, "~> 3.1"},
      {:credo, "~> 1.0.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.10.0", only: [:test]},
      {:ex_doc, "~> 0.14", only: :dev},
      {:exvcr, "~> 0.10", only: :test},
      {:faker, "~> 0.12.0", only: :test},
      {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test]},
      {:microformats2, "~> 0.2.0"}
    ]
  end

  defp package() do
    [
      name: "indieweb",
      description:
        "Collection of common IndieWeb utilites like authorship resolution, Webmention, post type discovery and IndieAuth.",
      licenses: ["APGL v3.0"],
      links: %{
        "Source Code" => "https://git.jacky.wtf/indieweb/elixir",
        "IndieWeb" => "https://indieweb.org",
        "IndieAuth spec" => "https://indieauth.spec.indieweb.org"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      ci: ["test --include slow:true --cover", "coveralls.detail", "inch"]
    ]
  end
end
