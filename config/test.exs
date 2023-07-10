config :autocontext, ecto_repos: [Autocontext.Repo]

config :autocontext, repo: Autocontext.Repo

config :autocontext, Autocontext.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "autocontext_test",
  hostname: "db",
  poolsize: 10
