defmodule Ordo.Authentication do
  alias Ordo.Repo
  alias Ordo.Authentication

  # Queries

  def get_session(session_id) do
    with %{} = session <- Repo.get(Authentication.Projections.Session, session_id) do
      Repo.preload(session, [:account])
    end
  end

  def get_actor_by_session_id(session_id) do
    session_id
    |> get_session()
    |> case do
      nil ->
        {:error, :session_not_found}

      %{} = session ->
        {:ok, Ordo.Actor.build(session)}
    end
  end

  @spec get_corpo_actor(Ordo.Actor.t(), String.t()) ::
          {:ok, Ordo.Actor.t()} | {:error, :no_access_to_corpo}
  def get_corpo_actor(actor, corpo_id) do
    Authentication.Projections.Employee
    |> Ordo.Repo.get_by(%{account_id: actor.account.id, corpo_id: corpo_id})
    |> case do
      %Authentication.Projections.Employee{} = employee ->
        employee = Repo.preload(employee, :corpo)

        {:ok, Ordo.Actor.set_corpo(actor, employee)}

      nil ->
        {:error, :no_access_to_corpo}
    end
  end

  # Actions

  @spec create_session(Ordo.Actor.t()) :: {:ok, String.t()}
  def create_session(actor) do
    with {:ok, command} <- Authentication.Commands.CreateSession.build(actor),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, command.session_id}
    end
  end

  def delete_session(_session_id) do
    :ok
  end

  @spec verify_session(String.t()) :: :ok | {:error, any()}
  def verify_session(session_id) do
    with {:ok, command} <- Authentication.Commands.VerifySession.build(session_id) do
      Ordo.App.dispatch(command)
    end
  end

  @spec sign_in(map()) ::
          {:ok, String.t()} | {:error, :invalid_credentials} | {:error, Ecto.Changeset.t()}
  def sign_in(params) do
    with {:ok, command} <-
           Authentication.Commands.SignIn.build(params),
         :ok <- Ordo.App.dispatch(command) do
      account =
        Repo.get_by!(Authentication.Projections.Account, [email: command.email],
          skip_org_id: true
        )

      {:ok, Ordo.Actor.build(%{account: account})}
    end
  end

  def sign_in_changeset(command \\ %Authentication.Commands.SignIn{}, attrs) do
    Authentication.Commands.SignIn.changeset(command, attrs)
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
