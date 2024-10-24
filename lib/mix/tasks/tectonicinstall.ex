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

    if opts[:if_missing] && latest_version?() do
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

  defp latest_version?() do
    version = Tectonic.configured_version()
    match?({:ok, ^version}, Tectonic.bin_version())
  end
end
