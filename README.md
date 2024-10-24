[![hex.pm](https://img.shields.io/hexpm/l/tectonic.svg)](https://hex.pm/packages/tectonic)
[![hex.pm](https://img.shields.io/hexpm/v/tectonic.svg)](https://hex.pm/packages/tectonic)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/tectonic)
[![hex.pm](https://img.shields.io/hexpm/dt/tectonic.svg)](https://hex.pm/packages/tectonic)
[![github.com](https://img.shields.io/github/last-commit/frankdugan3/tectonic.svg)](https://github.com/frankdugan3/tectonic)

# Tectonic

Mix tasks for installing and invoking [tectonic](https://tectonic-typesetting.github.io/), a modernized, complete, self-contained
[TeX](https://en.wikipedia.org/wiki/TeX)/[LaTeX](https://www.latex-project.org/)
engine, powered by [XeTeX](http://xetex.sourceforge.net/) and
[TeXLive](https://www.tug.org/texlive/).

**This is an adaptation of [the Elixir Tailwind installer](https://github.com/phoenixframework/tailwind) made by Wojtek Mach and José Valim.**

## Installation

However, if your assets are precompiled during development,
then it only needs to be a dev dependency:

```elixir
def deps do
  [
    {:tectonic, "~> 0.1"}
  ]
end
```

Once installed, change your `config/config.exs` to pick your
tectonic version of choice:

```elixir
config :tectonic, version: "0.15.0"
```

Now you can install tectonic by running:

```bash
$ mix tectonic.install
```

or if your platform isn't officially supported by Tectonic,
you can supply a third party path to the binary the installer wants
(beware that we cannot guarantee the compatibility of any third party executable):

```bash
$ mix tectonic.install [url]
```

And invoke tectonic with:

```bash
$ mix tectonic default -X compile --untrusted myfile.tex
```

You can also use it within your Elixir code:

```elixir
Tectonic.run(:default, ~w[-X compile --untrusted myfile.tex])
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
  default: [
    args: ~w(
      -X compile
      --untrusted
    )
  ]
```

When `mix tectonic default` is invoked, the task arguments will be appended
to the ones configured above. Note profiles must be configured in your
`config/config.exs`, as `tectonic` runs without starting your application
(and therefore it won't pick settings in `config/runtime.exs`).

## License

Copyright (c) 2024 Frank Polasek Dugan III.

Tectonic source code is licensed under the [MIT License](LICENSE.md).
