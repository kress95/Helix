use Mix.Config

prefix = System.get_env("HELIX_DB_PREFIX") || "helix"

config :helix, Helix.Server.Repo,
  database: prefix <> "_dev_server"
