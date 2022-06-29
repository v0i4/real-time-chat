import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chat, ChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "trKwMxd3w5J0VKAyffnIFBuUDTbB7QfbI5I6L+e/W2XOKO3yA8YDVSVyQAgscCfG",
  server: false

# In test we don't send emails.
config :chat, Chat.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
