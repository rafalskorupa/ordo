defmodule Ordo.Authentication do
  alias Ordo.Repo
  alias Ordo.Authentication

  # Actions

  @spec sign_in(map()) :: {:ok, String.t()} | {:error, Ecto.Changeset.t()}
  def sign_in(params) do
    with {:ok, command} <-
           Authentication.Commands.SignIn.build(params),
         :ok <- Ordo.App.dispatch(command) do
      account =
        Repo.get_by!(Authentication.Projections.Account, [email: params.email], skip_org_id: true)

      {:ok, Ordo.Actor.build(%{account: account})}
    end
  end

  def sign_in_changeset(command \\ %Authentication.Commands.SignIn{}, attrs) do
    Authentication.Commands.SignIn.changeset(command, %{})
  end

  @spec register(map()) :: :ok | {:error, Ecto.Changeset.t()}
  def register(attrs) do
    with {:ok, command} <- Authentication.Commands.Register.build(attrs) do
      Ordo.App.dispatch(command, consistency: :strong)
    end
  end

  @spec register_changeset(map()) :: Ecto.Changeset.t()
  @spec register_changeset(Authentication.Commands.Register.t(), map()) :: Ecto.Changeset.t()
  def register_changeset(command \\ %Authentication.Commands.Register{}, attrs) do
    Authentication.Commands.Register.changeset(command, attrs)
  end

  @spec update_password(Ordo.Actor.t(), map()) :: :ok | {:error, Ecto.Changeset.t()}
  def update_password(%{account: %{}} = actor, attrs) do
    with {:ok, command} <- Authentication.Commands.UpdatePassword.build(actor, attrs) do
      Ordo.App.dispatch(command, consistency: :strong)
    end
  end

  @spec update_password_changeset(map()) :: Ecto.Changeset.t()
  @spec update_password_changeset(Authentication.Commands.UpdatePassword.t(), map()) ::
          Ecto.Changeset.t()
  def update_password_changeset(command \\ %Authentication.Commands.UpdatePassword{}, attrs) do
    Authentication.Commands.UpdatePassword.changeset(command, attrs)
  end
end
