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

  test "installs with custom URL" do
    assert :ok = Mix.Task.rerun("tectonic.install", [Tectonic.default_base_url()])
  end
end
