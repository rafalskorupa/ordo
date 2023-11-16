defmodule Ordo.Authentication.Commands.SignIn do
  defstruct [:email, :password]

  def build(%{email: email, password: password}) do
    {:ok, %__MODULE__{email: email, password: password}}
  end
end
