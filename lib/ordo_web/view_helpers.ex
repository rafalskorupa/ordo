defmodule OrdoWeb.ViewHelpers do
  def employee_name(%{first_name: first_name, last_name: last_name}) do
    [first_name, last_name] |> Enum.join(" ")
  end

  def employee_name(_), do: ""

  def employee_email(%{account: %{email: email}}), do: email
  def employee_email(%{invitations: [%{email: email} | _]}), do: email
  def employee_email(_), do: nil

  def employee_has_account?(%{account: %{email: _email}}), do: true
  def employee_has_account?(_), do: false

  def employee_status(%{account: %{}}), do: "User"
  def employee_status(%{invitations: [%{} | _]}), do: "Invited"
  def employee_status(_), do: nil
end
