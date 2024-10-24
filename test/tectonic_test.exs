defmodule TectonicTest do
  use ExUnit.Case, async: true

  @version Tectonic.latest_version()

  setup do
    Application.put_env(:tectonic, :version, @version)
    :ok
  end

  test "run on default" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Tectonic.run(:default, ["--version"]) == 0
           end) =~ @version
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Tectonic.run(:another, []) == 0
           end) =~ @version
  end

  test "updates on install" do
    Application.put_env(:tectonic, :version, "0.14.1")
    Mix.Task.rerun("tectonic.install", ["--if-missing"])

    assert ExUnit.CaptureIO.capture_io(fn ->
             # This hack is because the previous release no longer runs due to old SSL (Arch BTW).
             assert Tectonic.run(:another, []) == 127
           end) =~ "libssl.so.1.1"

    Application.delete_env(:tectonic, :version)

    Mix.Task.rerun("tectonic.install", ["--if-missing"])

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Tectonic.run(:default, ["--version"]) == 0
           end) =~ @version
  end

  test "installs with custom URL" do
    assert :ok = Mix.Task.rerun("tectonic.install", [Tectonic.default_base_url()])
  end
end
