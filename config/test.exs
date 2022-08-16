import Config

config :confeature, Test.Repo,
  hostname: "localhost",
  database: "confeature_test",
  username: "postgres",
  password: "postgres",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true

config :confeature, ecto_repos: [
    Test.Repo
  ]

config :logger, level: :info
