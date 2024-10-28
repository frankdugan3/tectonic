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
      tidbit: [
        hidden?: true
      ],
      important: [
        header: "Important Changes"
      ]
    ],
    tags: [
      allow_untagged?: true
    ],
    manage_mix_version?: true,
    manage_readme_version: "README.md",
    version_tag_prefix: "v"
end
