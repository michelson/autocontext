use Mix.Config

config :autocontext, ecto_repos: [Autocontext.Repo]

config :autocontext, repo: Autocontext.Repo

config :autocontext, Autocontext.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "autocontext_test",
  hostname: "localhost",
  poolsize: 10,
  pool: Ecto.Adapters.SQL.Sandbox

# import_config "#{Mix.env()}.exs"
