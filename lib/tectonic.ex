defmodule Tectonic do
  # https://github.com/tectonic-typesetting/tectonic/releases
  @latest_version "0.15.0"

  @moduledoc """
  Tectonic is an installer and runner for [tectonic](https://tectonic-typesetting.github.io), a modernized, complete, self-contained
  [TeX](https://en.wikipedia.org/wiki/TeX)/[LaTeX](https://www.latex-project.org/)
  engine, powered by [XeTeX](http://xetex.sourceforge.net/) and
  [TeXLive](https://www.tug.org/texlive/).

  ## Profiles

  You can define multiple tectonic profiles. By default, there is a
  profile called `:default` which you can configure its args, current
  directory and environment:

      config :tectonic,
        version: "#{@latest_version}",
        default: [
          args: ~w(
            -X compile
            --untrusted
          )
        ]

  ## Tectonic configuration

  There are two global configurations for the tectonic application:

    * `:version` - the expected tectonic version

    * `:version_check` - whether to perform the version check or not.
      Useful when you manage the tectonic executable with an external
      tool (e.g. OS package manager)

    * `:cacerts_path` - the directory to find certificates for
      https connections

    * `:path` - the path to find the tectonic executable at. By
      default, it is automatically downloaded and placed inside
      the `_build` directory of your current app

  Overriding the `:path` is not recommended, as we will automatically
  download and manage `tectonic` for you. But in case you can't download
  it (for example, GitHub behind a proxy), you may want to
  set the `:path` to a configurable system location.

  Once you find the location of the executable, you can store it in a
  `MIX_TECTONIC_PATH` environment variable, which you can then read in
  your configuration file:

      config :tectonic, path: System.get_env("MIX_TECTONIC_PATH")
  """

  use Application
  require Logger

  @doc false
  def start(_, _) do
    if Application.get_env(:tectonic, :version_check, true) do
      unless Application.get_env(:tectonic, :version) do
        Logger.warning("""
        tectonic version is not configured. Please set it in your config files:

            config :tectonic, :version, "#{latest_version()}"
        """)
      end

      configured_version = configured_version()

      case bin_version() do
        {:ok, ^configured_version} ->
          :ok

        {:ok, version} ->
          Logger.warning("""
          Outdated tectonic version. Expected #{configured_version}, got #{version}. \
          Please run `mix tectonic.install` or update the version in your config files.\
          """)

        :error ->
          :ok
      end
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc false
  # Latest known version at the time of publishing.
  def latest_version, do: @latest_version

  @doc """
  Returns the configured tectonic version.
  """
  def configured_version do
    Application.get_env(:tectonic, :version, latest_version())
  end

  @doc """
  Returns the configuration for the given profile.

  Returns nil if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:tectonic, profile) ||
      raise ArgumentError, """
      unknown tectonic profile. Make sure the profile is defined in your config/config.exs file, such as:

          config :tectonic,
            version: "#{@latest_version}",
            #{profile}: [
              args: ~w(
                -X compile
                --untrusted
              )
            ]
      """
  end

  @doc """
  Returns the path to the executable.

  The executable may not be available if it was not yet installed.
  """
  def bin_path do
    name = "tectonic-#{target()}"

    Application.get_env(:tectonic, :path) ||
      if Code.ensure_loaded?(Mix.Project) do
        Path.join(Path.dirname(Mix.Project.build_path()), name)
      else
        Path.expand("_build/#{name}")
      end
  end

  @doc """
  Returns the version of the tectonic executable.

  Returns `{:ok, version_string}` on success or `:error` when the executable
  is not available.
  """
  def bin_version do
    path = bin_path()

    with true <- File.exists?(path),
         {out, 0} <- System.cmd(path, ["--help"]),
         [vsn] <- Regex.run(~r/tectonic v([^\s]+)/, out, capture: :all_but_first) do
      {:ok, vsn}
    else
      _ -> :error
    end
  end

  @doc """
  Runs the given command with `args`.

  The given args will be appended to the configured args.
  The task output will be streamed directly to stdio. It
  returns the status of the underlying call.
  """
  def run(profile, extra_args \\ []) when is_atom(profile) and is_list(extra_args) do
    config = config_for!(profile)
    args = config[:args] || []

    env =
      config
      |> Keyword.get(:env, %{})

    opts = [
      cd: config[:cd] || File.cwd!(),
      env: env,
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    bin_path()
    |> System.cmd(args ++ extra_args, opts)
    |> elem(1)
  end

  @doc """
  Installs, if not available, and then runs `tectonic`.

  Returns the same as `run/2`.
  """
  def install_and_run(profile, args) do
    unless File.exists?(bin_path()) do
      install()
    end

    run(profile, args)
  end

  @doc """
  The default URL to install Tectonic from.
  """
  def default_base_url do
    "https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%40$version/tectonic-$version-$target.$extension"
  end

  @doc """
  Installs tectonic with `configured_version/0`.
  """
  def install(base_url \\ default_base_url()) do
    url = get_url(base_url)

    tmp_opts = if System.get_env("MIX_XDG"), do: %{os: :linux}, else: %{}

    tmp_dir =
      freshdir_p(:filename.basedir(:user_cache, "mix-tectonic", tmp_opts)) ||
        freshdir_p(Path.join(System.tmp_dir!(), "mix-tectonic")) ||
        raise "could not install tectonic. Set MIX_XGD=1 and then set XDG_CACHE_HOME to the path you want to use as cache"

    compressed = fetch_body!(url)

    download_path =
      case extension() do
        "zip" ->
          case :zip.unzip(compressed, cwd: to_charlist(tmp_dir)) do
            {:ok, [download_path]} -> download_path
            # OTP 27.1 and newer versions return both the unzipped folder and file
            {:ok, [_download_folder, download_path]} -> download_path
            other -> raise "couldn't unpack archive: #{inspect(other)}"
          end

        _ ->
          case :erl_tar.extract({:binary, compressed}, [:compressed, cwd: to_charlist(tmp_dir)]) do
            :ok ->
              case :os.type() do
                {:win32, _} ->
                  Path.join([tmp_dir, "tectonic.exe"])

                _ ->
                  Path.join([tmp_dir, "tectonic"])
              end

            other ->
              raise "couldn't unpack archive: #{inspect(other)}"
          end
      end

    bin_path = bin_path()
    File.mkdir_p!(Path.dirname(bin_path))

    File.cp!(download_path, bin_path)
    File.chmod(bin_path, 0o755)
  end

  defp freshdir_p(path) do
    with {:ok, _} <- File.rm_rf(path),
         :ok <- File.mkdir_p(path) do
      path
    else
      _ -> nil
    end
  end

  defp target do
    arch_str = :erlang.system_info(:system_architecture)
    [arch | _] = arch_str |> List.to_string() |> String.split("-")

    # TODO: There are a few more options, e.g. musl, should add them.
    case {:os.type(), arch, :erlang.system_info(:wordsize) * 8} do
      {{:win32, _}, _arch, 64} -> "x86_64-pc-windows-msvc"
      {{:unix, :darwin}, arch, 64} when arch in ~w(arm aarch64) -> "aarch64-apple-darwin"
      {{:unix, :darwin}, "x86_64", 64} -> "x86_64-apple-darwin"
      {{:unix, :linux}, "aarch64", 64} -> "aarch64-unknown-linux-musl"
      {{:unix, :linux}, "arm", 32} -> "arm-unknown-linux-musleabihf"
      {{:unix, :linux}, "armv7" <> _, 32} -> "arm-unknown-linux-musleabihf"
      {{:unix, _osname}, arch, 64} when arch in ~w(x86_64 amd64) -> "x86_64-unknown-linux-gnu"
      {{:unix, _osname}, arch, 32} when arch in ~w(x86_64 amd64) -> "i686-unknown-linux-gnu"
      {_os, _arch, _wordsize} -> raise "tectonic is not available for architecture: #{arch_str}"
    end
  end

  defp fetch_body!(url, retry \\ true) do
    scheme = URI.parse(url).scheme
    url = String.to_charlist(url)
    Logger.debug("Downloading tectonic from #{url}")

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    if proxy = proxy_for_scheme(scheme) do
      %{host: host, port: port} = URI.parse(proxy)
      Logger.debug("Using #{String.upcase(scheme)}_PROXY: #{proxy}")
      set_option = if "https" == scheme, do: :https_proxy, else: :proxy
      :httpc.set_options([{set_option, {{String.to_charlist(host), port}, []}}])
    end

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    cacertfile = cacertfile() |> String.to_charlist()

    http_options =
      [
        ssl: [
          verify: :verify_peer,
          cacertfile: cacertfile,
          depth: 2,
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ],
          versions: protocol_versions()
        ]
      ]
      |> maybe_add_proxy_auth(scheme)

    options = [body_format: :binary]

    case {retry, :httpc.request(:get, {url, []}, http_options, options)} do
      {_, {:ok, {{_, 200, _}, _headers, body}}} ->
        body

      {true, {:error, {:failed_connect, [{:to_address, _}, {inet, _, reason}]}}}
      when inet in [:inet, :inet6] and
             reason in [:ehostunreach, :enetunreach, :eprotonosupport, :nxdomain] ->
        :httpc.set_options(ipfamily: fallback(inet))
        fetch_body!(url, false)

      other ->
        raise """
        Couldn't fetch #{url}: #{inspect(other)}

        This typically means we cannot reach the source or you are behind a proxy.
        You can try again later and, if that does not work, you might:

          1. If behind a proxy, ensure your proxy is configured and that
             your certificates are set via the cacerts_path configuration

          2. Manually download the executable from the URL above and
             place it inside "_build/tectonic-#{target()}"
        """
    end
  end

  defp fallback(:inet), do: :inet6
  defp fallback(:inet6), do: :inet

  defp proxy_for_scheme("http") do
    System.get_env("HTTP_PROXY") || System.get_env("http_proxy")
  end

  defp proxy_for_scheme("https") do
    System.get_env("HTTPS_PROXY") || System.get_env("https_proxy")
  end

  defp maybe_add_proxy_auth(http_options, scheme) do
    case proxy_auth(scheme) do
      nil -> http_options
      auth -> [{:proxy_auth, auth} | http_options]
    end
  end

  defp proxy_auth(scheme) do
    with proxy when is_binary(proxy) <- proxy_for_scheme(scheme),
         %{userinfo: userinfo} when is_binary(userinfo) <- URI.parse(proxy),
         [username, password] <- String.split(userinfo, ":") do
      {String.to_charlist(username), String.to_charlist(password)}
    else
      _ -> nil
    end
  end

  defp cacertfile() do
    Application.get_env(:tectonic, :cacerts_path) || CAStore.file_path()
  end

  defp protocol_versions do
    if otp_version() < 25, do: [:"tlsv1.2"], else: [:"tlsv1.2", :"tlsv1.3"]
  end

  defp otp_version do
    :erlang.system_info(:otp_release) |> List.to_integer()
  end

  defp extension() do
    case target() do
      "x86_64-pc-windows-msvc" -> "zip"
      _ -> "tar.gz"
    end
  end

  defp get_url(base_url) do
    base_url
    |> String.replace("$version", configured_version())
    |> String.replace("$target", target())
    |> String.replace("$extension", extension())
  end
end
