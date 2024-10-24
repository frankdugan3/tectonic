import Config

config :tectonic,
  version: "0.15.0",
  another: [
    args: ["--version"]
  ]

if Mix.env() == :dev do
  config :git_ops,
    mix_project: Mix.Project.get!(),
    changelog_file: "CHANGELOG.md",
    repository_url: "https://github.com/frankdugan3/tectonic",
    types: [
      # Makes an allowed commit type called `tidbit` that is not
      # shown in the changelog
      tidbit: [
        hidden?: true
      ],
      # Makes an allowed commit type called `important` that gets
      # a section in the changelog with the header "Important Changes"
      important: [
        header: "Important Changes"
      ]
    ],
    tags: [
      # Filter out or not commits that don't contain tags
      allow_untagged?: true
    ],
    # Instructs the tool to manage your mix version in your `mix.exs` file
    # See below for more information
    manage_mix_version?: true,
    # Instructs the tool to manage the version in your README.md
    # Pass in `true` to use `"README.md"` or a string to customize
    manage_readme_version: "README.md",
    version_tag_prefix: "v"
end
