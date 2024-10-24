defmodule Mix.Tasks.Tectonic do
  @moduledoc """
  Invokes tectonic with the given args.

  Usage:

      $ mix tectonic TASK_OPTIONS PROFILE TECTONIC_ARGS

  Example:

      $ mix tectonic default -X compile --untrusted myfile.tex

  If tectonic is not installed, it is automatically downloaded.
  Note the arguments given to this task will be appended
  to any configured arguments.

  ## Options

    * `--runtime-config` - load the runtime configuration
      before executing command

  Note flags to control this Mix task must be given before the
  profile:

      $ mix tectonic --runtime-config default
  """

  @shortdoc "Invokes tectonic with the profile and args"
  @compile {:no_warn_undefined, Mix}

  use Mix.Task

  @impl true
  def run(args) do
    switches = [runtime_config: :boolean]
    {opts, remaining_args} = OptionParser.parse_head!(args, switches: switches)

    if function_exported?(Mix, :ensure_application!, 1) do
      Mix.ensure_application!(:inets)
      Mix.ensure_application!(:ssl)
    end

    if opts[:runtime_config] do
      Mix.Task.run("app.config")
    else
      Mix.Task.run("loadpaths")
      Application.ensure_all_started(:tectonic)
    end

    Mix.Task.reenable("tectonic")
    install_and_run(remaining_args)
  end

  defp install_and_run([profile | args] = all) do
    case Tectonic.install_and_run(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix tectonic #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  defp install_and_run([]) do
    Mix.raise("`mix tectonic` expects the profile as argument")
  end
end
