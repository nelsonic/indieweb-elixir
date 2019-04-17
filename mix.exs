defmodule IndieWeb.MixProject do
  use Mix.Project
  @description "Helpers and facilities for working with the IndieWeb."

  def project do
    [
      aliases: aliases(),
      app: :indieweb,
      name: "IndieWeb",
      version: "0.0.42",
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
        source_url_pattern:
          "https://git.jacky.wtf/indieweb/elixir/src/branch/master/%{path}#L%{line}",
        logo: "priv/static/images/logo.png",
        extras: Path.wildcard("docs/*.markdown")
      ]
    ]
  end

  def application do
    [
      mod: {IndieWeb.Application, []},
      extra_applications: [:logger, :cachex, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:apex, "~> 1.2.1", only: [:dev, :test]},
      {:cachex, "~> 3.1.0"},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10.0", only: [:test]},
      {:exvcr, "~> 0.10.0", only: :test, runtime: false},
      {:faker, "~> 0.12.0", only: :test, runtime: false},
      {:jason, "~> 1.0"},
      {:hackney, "~> 1.15.1"},
      {:microformats2, "~> 0.2.0"},
      {:tesla,
       git: "https://github.com/jalcine/tesla",
       branch: "jalcine/check-regex-run-results",
       override: true},
      {:tesla_request_id, "~> 0.2.0"}
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
      ci: ["test --include slow:true --cover", "coveralls.detail"]
    ]
  end
end
