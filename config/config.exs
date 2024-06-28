import Config

config :dog_api, [
  attempt: 1,
  include_404s: false,
  max_attempts: 5,
  retry_unknown_errors: false,
  wait: 1
]

config :dog_api, ecto_repos: [DogAPI.Repo]

config :dog_api, DogAPI.Repo,
  database: "dog_api",
  hostname: "localhost",
  password: "nicmos6922",
  pool_size: 10,
  show_sensitive_data_on_connection_error: true,
  username: "kapranov"

config :opentelemetry,
  :processors,
  otel_batch_processor: %{
    exporter: {:opentelemetry_exporter, %{endpoints: [{:http, 'localhost', '0.0.0.0', []}]}}
  }

config :dog_api, [
  access_key_id: "VYPQIQWQEFQ3PWORFF4Y",
  api_openweathermap: "49b668e20c64868556366c8dda7ac8a4",
  bucket: "taxgig",
  region: "nyc3",
  secret_access_key: "qKDzXvnTdQxhVmp4hBa9MnJw/5A/SG35m8AvQMBCwOI"
]
