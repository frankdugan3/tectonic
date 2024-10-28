defmodule Tectonic.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/frankdugan3/tectonic"

  def project do
    [
      app: :tectonic,
      version: @version,
      elixir: "~> 1.17",
      deps: deps(),
      docs: docs(),
      description: "Mix tasks for installing and invoking tectonic",
      package: [
        links: %{
          "GitHub" => @source_url,
          "tectonic" => "https://tectonic-typesetting.github.io"
        },
        licenses: ["MIT"]
      ],
      aliases: [test: ["tectonic.install --if-missing", "test"]]
    ]
  end

  defp docs do
    [
      main: "about",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["CHANGELOG.md"],
      output: "doc",
      extra_section: "Guides",
      extras: extras()
    ]
  end

  defp extras do
    ordered =
      [
        {"documentation/about.md", [default: true]},
        "documentation/tutorials/get-started.md",
        "CHANGELOG.md"
      ]

    unordered = Path.wildcard("documentation/**/*.{md,cheatmd,livemd}")

    Enum.uniq_by(ordered ++ unordered, fn
      {file, _opts} -> file
      file -> file
    end)
  end

  def application do
    [
      extra_applications: [:logger, inets: :optional, ssl: :optional],
      mod: {Tectonic, []},
      env: [default: []]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :docs},
      {:git_ops, "~> 2.6.1", only: :dev},
      {:castore, ">= 0.0.0"},
      {:igniter, "~> 0.3"}
    ]
  end
end
