defmodule Autocontext.MixProject do
  use Mix.Project

  def project do
    [
      app: :autocontext,
      version: "0.1.0",
      elixir: "~> 1.14",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Autocontext acts as ActiveRecord callbacks",
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto, "~> 3.10.0"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},
      {:mox, "~> 1.0", only: :test}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [
      name: :taglet,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["michelson"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/michelson/autocontext",
        "Docs" => "https://hexdocs.pm/michelson/autocontext.html"
      }
    ]
  end

  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:ci), do: ["lib", "test/support"]
end
