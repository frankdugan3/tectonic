defmodule Mix.Tasks.Tectonic.Install do
  @moduledoc """
  Installs Tectonic executable.

     $ mix tectonic.install
     $ mix tectonic.install --if-missing

  By default, it installs #{Tectonic.latest_version()} but you
  can configure it in your config files, such as:

     config :tectonic, :version, "#{Tectonic.latest_version()}"

  ## Options

     * `--runtime-config` - load the runtime configuration
       before executing command

     * `--if-missing` - install only if the given version
       does not exist
  """

  @shortdoc "Installs Tectonic executable"
  @compile {:no_warn_undefined, Mix}

  use Mix.Task

  @impl true
  def run(args) do
    valid_options = [runtime_config: :boolean, if_missing: :boolean]

    {opts, base_url} =
      case OptionParser.parse_head!(args, strict: valid_options) do
        {opts, []} ->
          {opts, Tectonic.default_base_url()}

        {opts, [base_url]} ->
          {opts, base_url}

        {_, _} ->
          Mix.raise("""
          Invalid arguments to tectonic.install, expected one of:

              mix tectonic.install
              mix tectonic.install '#{Tectonic.default_base_url()}'
              mix tectonic.install --runtime-config
              mix tectonic.install --if-missing
          """)
      end

    if opts[:runtime_config], do: Mix.Task.run("app.config")

    if opts[:if_missing] && Tectonic.configured_version_installed?() do
      :ok
    else
      if function_exported?(Mix, :ensure_application!, 1) do
        Mix.ensure_application!(:inets)
        Mix.ensure_application!(:ssl)
      end

      Mix.Task.run("loadpaths")
      Tectonic.install(base_url)
    end
  end

  @behaviour Igniter.Mix.Task

  @impl Igniter.Mix.Task
  @doc false
  def installer?, do: true

  @impl Igniter.Mix.Task
  @doc false
  def supports_umbrella?, do: false

  @impl Igniter.Mix.Task
  @doc false
  def info(_argv, _parent), do: %Igniter.Mix.Task.Info{extra_args?: true}

  @impl Igniter.Mix.Task
  @doc false
  def igniter(igniter, _argv) do
    igniter
    |> Igniter.Project.Config.configure(
      "config.exs",
      :tectonic,
      [:version],
      Tectonic.latest_version()
    )
    |> Igniter.Project.Config.configure(
      "config.exs",
      :tectonic,
      [:compile, :args],
      ~w(-X compile)
    )
    |> Igniter.Project.Config.configure(
      "config.exs",
      :tectonic,
      [:compile, :env],
      %{TECTONIC_UNTRUSTED_MODE: true}
    )
  end
end
