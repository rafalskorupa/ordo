defmodule OrdoWeb.ViewHelpers do
  def employee_name(%{first_name: first_name, last_name: last_name}) do
    [first_name, last_name] |> Enum.reject(&is_nil/1) |> Enum.join(" ")
  end

  def employee_name(_), do: ""

  def employee_name!(employee) do
    case employee_name(employee) do
      "" -> "Unnamed Employee"
      name -> name
    end
  end

  def employee_email(%{account: %{email: email}}), do: email
  def employee_email(%{invitations: [%{email: email} | _]}), do: email
  def employee_email(_), do: nil

  def employee_has_account?(%{account: %{email: _email}}), do: true
  def employee_has_account?(_), do: false

  def employee_status(%{account: %{}}), do: "User"
  def employee_status(%{invitations: [%{} | _]}), do: "Invited"
  def employee_status(_), do: nil

  def task_name!(nil), do: "Task"
  def task_name!(%{name: name}), do: name

  def employee_initials(employee) do
    [
      employee.first_name || "?",
      employee.last_name || "?"
    ]
    |> Enum.map_join("", &String.at(&1, 0))
  end

  def employee_initalis(nil), do: "??"

  def actor_already_assigned?(%{employee: %{id: id}}, employees) do
    Enum.find(employees, &(&1.id == id))
  end
end
