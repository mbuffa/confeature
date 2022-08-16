defmodule Confeature.MixProject do
  use Mix.Project

  def project do
    [
      app: :confeature,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package()
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
      {:ecto, ">= 3.5.0"},
      {:ecto_sql, ">= 3.7.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.3", only: :test},
      {:redix, "~> 1.1", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README", "LICENSE*"],
      maintainers: ["Maxime Buffa"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbuffa/confeature"}
    ]
  end
end
