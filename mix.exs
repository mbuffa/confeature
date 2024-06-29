defmodule Confeature.MixProject do
  use Mix.Project

  def project do
    [
      app: :confeature,
      version: "0.1.2",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      # Hex
      package: package(),
      aliases: aliases(),
      description: "Store your application-wide settings, on top of Ecto and your caching layer.",

      # Docs
      name: "Confeature",
      source_url: "https://github.com/mbuffa/confeature",
      docs: [
        main: "Confeature",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() == :test do
      [
        mod: {Test.Application, []},
        extra_applications: [:logger]
      ]
    else
      [
        extra_applications: [:logger]
      ]
    end
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, ">= 3.7.0"},
      {:ecto_sql, ">= 3.7.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:redix, "~> 1.5", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE*"],
      maintainers: ["Maxime Buffa"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbuffa/confeature"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create", "ecto.migrate", "test"]
    ]
  end
end
