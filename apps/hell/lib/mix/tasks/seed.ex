defmodule Mix.Tasks.Helix.Seed do

  use Mix.Task

  @recursive true

  @found "Applying seeds"
  @not_found "No seeds found"

  @found_pad String.duplicate(" ", div(80 - String.length(@found), 2))
  @not_found_pad String.duplicate(" ", div(80 - String.length(@not_found), 2))

  @found_msg IO.ANSI.green() <> @found_pad <> @found <> @found_pad <> IO.ANSI.default_color()
  @not_found_msg IO.ANSI.green() <> @not_found_pad <> @not_found <> @not_found_pad <> IO.ANSI.default_color()

  @line_div IO.ANSI.cyan() <> String.duplicate("=", 80) <> IO.ANSI.default_color()

  def run(_argv \\ []) do
    Mix.Task.run("compile", [])
    Mix.Task.run("app.start", [])

    Keyword.get(Mix.Project.config, :seeds, [])
    |> show_message()
    |> Enum.map(&apply_directory/1)
    |> List.flatten()
    |> apply_seeds()
  end

  def show_message([]) do
    Mix.Shell.IO.info @line_div
    Mix.Shell.IO.info @not_found_msg
    Mix.Shell.IO.info @line_div
    []
  end

  def show_message(patterns) do
    Mix.Shell.IO.info @line_div
    Mix.Shell.IO.info @found_msg
    Mix.Shell.IO.info @line_div
    patterns
  end

  defp apply_directory(pattern) do
    "priv/seeds/" <> pattern
  end

  defp apply_seeds([file | remainder]) do
    if File.exists?(file) do
      Code.require_file(file)
    end
    apply_seeds(remainder)
  end

  defp apply_seeds([]),
    do: :ok
end