defmodule Helix.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()]
  end

  defp deps do
    [
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},
      {:credo, "~> 0.5", git: "https://github.com/rrrene/credo.git", ref: "9317fcb", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}]
  end

  defp aliases do
    [test: ["compile", "helix.test"]]
  end
end