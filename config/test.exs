import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ordo, Ordo.Repo,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: System.get_env("POSTGRES_DB") || "ordo_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool_size: 10

config :ordo, Ordo.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: System.get_env("POSTGRES_DB") || "ordo_eventstore_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool_size: 1

config :ordo, Oban, testing: :manual

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ordo, OrdoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "hkoAx7YuRNQecoF73uG20mJK0U+36gWqedRGt6uyxjSOeSy3URrMdTpul4pTzjh4",
  server: false

# In test we don't send emails.
config :ordo, Ordo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
