# Get Started

## Installation

<!-- tabs-open -->

### With Igniter (recommended)

First, to use `mix igniter.new`, the archive must be installed.

To install Igniter, run:

```bash
mix archive.install hex igniter_new
```

Then, install Tectonic:

```elixir
mix igniter.install tectonic
```

### Manual

Add the `tectonic` dependency to your `mix.exs`:

```elixir
defp deps do
  [
    {:tectonic, "~> 0.1"}
  ]
end
```

Edit `config/config.exs` to specificy the Tectonic version to install:

```elixir
config :tectonic, version: "0.15.0"
```

And then run `mix deps.get && mix deps.compile` to install the dependencies.

<!-- tabs-close -->

By default, the Tectonic binary will be automatically installed/updated at application startup.

You can also install it manually by running:

```bash
$ mix tectonic.install
```

or if your platform isn't officially supported by Tectonic,
you can supply a third party path to the binary:

```bash
$ mix tectonic.install [url]
```

And invoke tectonic with:

```bash
$ mix tectonic default -X compile --untrusted myfile.tex
```

You can also use it within your Elixir code:

```elixir
Tectonic.run(:default, ~w[-X compile myfile.tex])
```

The executable is kept at `_build/tectonic-TARGET`.
Where `TARGET` is your system target architecture.

## Profiles

The first argument to `tectonic` is the execution profile.
You can define multiple execution profiles with the current
directory, the OS environment, and default arguments to the
`tectonic` task:

```elixir
config :tectonic,
  version: "0.15.0",
  compile: [
    cd: "/tmp",
    env: %{TECTONIC_UNTRUSTED_MODE: true},
    args: ~w(
      -X compile
    )
  ]
```

When `mix tectonic compile` is invoked, the task arguments will be appended
to the ones configured above. Note profiles must be configured in your
`config/config.exs`, as `tectonic` runs without starting your application
(and therefore it won't pick settings in `config/runtime.exs`).
