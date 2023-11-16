defmodule Ordo.Support.CommandHelpers do
  def add_error(command, field, message) do
    command
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(field, message)
  end
end
