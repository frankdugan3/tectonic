defmodule Tectonic.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/frankdugan3/tectonic"

  def project do
    [
      app: :tectonic,
      version: @version,
      elixir: "~> 1.11",
      deps: deps(),
      description: "Mix tasks for installing and invoking tectonic",
      package: [
        links: %{
          "GitHub" => @source_url,
          "tectonic" => "https://tectonic-typesetting.github.io"
        },
        licenses: ["MIT"]
      ],
      docs: [
        main: "Tectonic",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: ["CHANGELOG.md"]
      ],
      aliases: [test: ["tectonic.install --if-missing", "test"]]
    ]
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
      {:git_ops, "~> 2.6.1", only: [:dev]},
      {:castore, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end
end
