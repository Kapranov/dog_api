defmodule DogAPI.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      aliases: aliases(),
      app: :dog_api,
      deps: deps(),
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ex_unit, :inets, :runtime_tools],
      mod: {DogAPI.Application, []}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.3"},
      {:broadway, "~> 1.0"},
      {:cabbage, "~> 0.4.1"},
      {:ecto_sql, "~> 3.11"},
      {:erlport, "~> 0.11.0"},
      {:ex_unit_notifier, "~> 1.3", only: [:test]},
      {:gen_stage, "~> 1.2"},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:multipart, "~> 0.4.0"},
      {:nimble_csv, "~> 1.2"},
      {:opentelemetry, "~> 1.3"},
      {:opentelemetry_exporter, "~> 1.6"},
      {:postgrex, "~> 0.17"},
      {:spark, "~> 2.0"},
      {:tesla, "~> 1.9"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      tag: &tag_release/1,
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup", "run priv/repo/seeds.exs"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp escript, do: []

  defp tag_release(_) do
    Mix.shell.info "Tagging release as #{@version}"
    System.cmd("git", ["tag", "-a", "v#{@version}", "-m", "v#{@version}"])
    System.cmd("git", ["push", "--tags"])
  end
end
