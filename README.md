[![hex.pm](https://img.shields.io/hexpm/l/tectonic.svg)](https://hex.pm/packages/tectonic)
[![hex.pm](https://img.shields.io/hexpm/v/tectonic.svg)](https://hex.pm/packages/tectonic)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/tectonic)
[![hex.pm](https://img.shields.io/hexpm/dt/tectonic.svg)](https://hex.pm/packages/tectonic)
[![github.com](https://img.shields.io/github/last-commit/frankdugan3/tectonic.svg)](https://github.com/frankdugan3/tectonic)

# Tectonic

Tooling to install and run [Tectonic](https://tectonic-typesetting.github.io/): A modernized, complete, self-contained
[TeX](https://en.wikipedia.org/wiki/TeX)/[LaTeX](https://www.latex-project.org/)
engine.

## Why this compiler?

Because the LaTeX ecosystem has been around for so long (TeX was first released in 1978!), it can be tricky to wrangle all the compilers, packages, etc. to get a _working_ build, and even harder to get _reproducible_ results from workstation to server.

Tectonic simplifies this process as a stand-alone executable that:

- Wraps both [XeTeX](http://xetex.sourceforge.net/) and
  [TeXLive](https://www.tug.org/texlive/)
- Automatically downloads support files
- Automatically loops Tex/BibTex to fully process the document
- Never asks for user interaction
- Fully supports OpenType fonts and Unicode

Check out the [Get Started](https://hexdocs.pm/tectonic/get-started.html) for installation and basic usage.

> **Note:** The installer code is adapted from the [Tailwind](https://github.com/phoenixframework/tailwind) and [ESBuild](https://github.com/phoenixframework/esbuild) installers, made by Wojtek Mach and José Valim.
