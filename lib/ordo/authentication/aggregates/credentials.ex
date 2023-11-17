defmodule Ordo.Authentication.Aggregates.Credentials do
  defstruct [:account_id, :email, :hashed_password]
  import Ordo.Support.CommandHelpers

  alias Ordo.Authentication.Aggregates.Credentials

  alias Ordo.Authentication.Commands.Register
  alias Ordo.Authentication.Commands.CreateAccount
  alias Ordo.Authentication.Commands.UpdatePassword
  alias Ordo.Authentication.Commands.SignIn

  alias Ordo.Authentication.Events.CredentialsCreated
  alias Ordo.Authentication.Events.PasswordChanged

  alias Ordo.Authentication.Password

  def execute(%Credentials{account_id: nil}, %Register{} = command) do
    %{
      email: email,
      password: password,
      account_id: account_id
    } = Register.validate!(command)

    :ok = Ordo.App.dispatch(%CreateAccount{account_id: account_id}, consistency: :strong)

    %CredentialsCreated{
      email: email,
      hashed_password: Password.hash_password(password),
      account_id: account_id
    }
  end

  def execute(%Credentials{}, %Register{} = command) do
    {:error, add_error(command, :email, "has already been taken")}
  end

  def execute(%Credentials{} = credentials, %UpdatePassword{} = command) do
    %{new_password: new_password, old_password: old_password} = UpdatePassword.validate!(command)

    if Password.password_valid?(credentials.hashed_password, old_password) do
      %PasswordChanged{
        account_id: credentials.account_id,
        hashed_password: Password.hash_password(new_password)
      }
    else
      {:error, :invalid_password}
    end
  end

  def execute(%Credentials{} = credentials, %SignIn{} = command) do
    %{password: password} = SignIn.validate!(command)

    if Password.password_valid?(credentials.hashed_password, password) do
      :ok
    else
      {:error, :invalid_credentials}
    end
  end

  def apply(%Credentials{}, %CredentialsCreated{} = event) do
    %Credentials{
      email: event.email,
      account_id: event.account_id,
      hashed_password: event.hashed_password
    }
  end

  def apply(%Credentials{} = credentials, %PasswordChanged{} = event) do
    %Credentials{credentials | hashed_password: event.hashed_password}
  end
end
