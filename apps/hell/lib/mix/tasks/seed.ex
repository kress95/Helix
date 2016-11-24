defmodule Mix.Tasks.Helix.Seed do

  use Mix.Task

  @content "Applying seeds"
  @pad String.duplicate(" ", div(80 - String.length(@content), 2))
  @line_div IO.ANSI.cyan() <> String.duplicate("=", 80) <> IO.ANSI.default_color()
  @msg IO.ANSI.green() <> @pad <> @content <> @pad <> IO.ANSI.default_color()
  @command IO.ANSI.cyan() <> "mix seed --only=prod" <> IO.ANSI.default_color()

  def run(argv \\ []) do
    Mix.Task.run("compile", [])

    {switches, _, _} = OptionParser.parse(argv, switches: [only: :string])

    Mix.Shell.IO.info @line_div
    Mix.Shell.IO.info @msg
    Mix.Shell.IO.info @line_div
    Mix.Shell.IO.info "If you want to apply just production seeds, run #{@command}"

    Keyword.get(switches, :only, :all)
    |> add_suffix()
    |> add_prefix()
    |> Path.wildcard()
    |> apply_seeds()
  end

  defp add_suffix(:all),
    do: "*.exs"

  defp add_suffix(env),
    do: "*_" <> env <> ".exs"

  defp add_prefix(suffix) do
    seed = Mix.Project.config |> Keyword.get(:seeds_path, "priv/seeds")
    path =
      if Mix.Project.umbrella? do
        apps = Mix.Project.config |> Keyword.get(:apps_path, "apps")
        apps <> "/*/" <> seed
      else
        seed
      end
    path <> "/" <> suffix
  end

  defp apply_seeds([file | remainder]) do
    Mix.Task.run("run", [file])
    apply_seeds(remainder)
  end

  defp apply_seeds([]),
    do: :ok
end