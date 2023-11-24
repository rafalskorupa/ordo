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

  def employee_initials(employee) do
    [
      String.at(employee.first_name, 0),
      String.at(employee.last_name, 0)
    ]
    |> Enum.join("")
    |> case do
      "" -> "??"
      initials -> initials
    end
  end

  def actor_already_assigned?(%{employee: %{id: id}}, employees) do
    Enum.find(employees, &(&1.id == id))
  end
end
