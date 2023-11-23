defmodule Ordo.PeopleFixtures do
  alias Ordo.People

  def create_employee(%{actor: actor}, attrs) do
    attrs = valid_employee_attributes(attrs)

    {:ok, employee} = People.create_employee(actor, attrs)

    %{employee: employee}
  end

  def valid_employee_attributes(attrs \\ %{}) do
    attrs
    |> Map.take([:first_name, :last_name])
    |> Enum.into(%{
      first_name: "Yorinobu",
      last_name: "Arasaka"
    })
  end
end
