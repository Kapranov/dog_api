defmodule DogApi.MixProject do
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
      mod: {DogApi.Application, []}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.3"},
      {:ex_unit_notifier, "~> 1.3", only: [:test]},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:multipart, "~> 0.4.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      tag: &tag_release/1
    ]
  end

  defp escript, do: []

  defp tag_release(_) do
    Mix.shell.info "Tagging release as #{@version}"
    System.cmd("git", ["tag", "-a", "v#{@version}", "-m", "v#{@version}"])
    System.cmd("git", ["push", "--tags"])
  end
end
