defmodule HELM.HELFBroker.Mixfile do
  use Mix.Project

  def project do
    [
      app: :helf_broker,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixirc_options: [warnings_as_errors: true],
      deps: deps]
  end

  def application do
    [
      applications: applications(Mix.env),
      mod: {HELM.HELFBroker.App, []}]
  end

  defp applications(_),
    do: [:logger, :hebroker]

  defp deps do
    [
      {:helf, git: "ssh://git@git.hackerexperience.com/diffusion/HELF/helf.git", ref: "dev_tester"},
      {:hebroker, git: "ssh://git@git.hackerexperience.com/diffusion/BROKER/HEBroker.git", ref: "v0.1"}]
  end
end
