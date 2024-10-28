# About

Tooling to install and run [Tectonic](https://tectonic-typesetting.github.io/): A modernized, complete, self-contained
[TeX](https://en.wikipedia.org/wiki/TeX)/[LaTeX](https://www.latex-project.org/)
engine.

## Tectonic

Because the LaTeX ecosystem has been around for so long (TeX was first released in 1978!), it can be tricky to wrangle all the compilers, packages, etc. to get a _working_ build, and even harder to get _reproducible_ results from workstation to server.

The Tectonic typesetting system simplifies this process as a stand-alone executable that:

- Wraps both [XeTeX](http://xetex.sourceforge.net/) and
  [TeXLive](https://www.tug.org/texlive/)
- Automatically downloads support files
- Automatically loops Tex/BibTex to fully process the document
- Never asks for user interaction
- Fully supports OpenType fonts and Unicode

Check out the [Get Started](get-started.md) guide for installation and basic usage.

> ### Attribution Notice {: .info}
>
> The installer code is adapted from the [Tailwind](https://github.com/phoenixframework/tailwind) and [ESBuild](https://github.com/phoenixframework/esbuild) installers, made by Wojtek Mach and José Valim.
