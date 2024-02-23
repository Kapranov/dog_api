import Config

config :dog_api, [
  attempt: 1,
  include_404s: false,
  max_attempts: 5,
  retry_unknown_errors: false,
  wait: 1
]

config :opentelemetry,
  :processors,
  otel_batch_processor: %{
    exporter: {:opentelemetry_exporter, %{endpoints: [{:http, 'localhost', '0.0.0.0', []}]}}
  }
