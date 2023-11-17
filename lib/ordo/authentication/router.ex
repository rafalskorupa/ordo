defmodule Ordo.Authentication.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.Authentication.Commands.Register,
      Ordo.Authentication.Commands.UpdatePassword,
      Ordo.Authentication.Commands.SignIn
    ],
    to: Ordo.Authentication.Aggregates.Credentials,
    identity: :email
  )

  dispatch(
    [Ordo.Authentication.Commands.CreateAccount, Ordo.Authentication.Commands.VerifyAccount],
    to: Ordo.Authentication.Aggregates.Account,
    identity: :account_id
  )

  dispatch(
    [
      Ordo.Authentication.Commands.CreateSession,
      Ordo.Authentication.Commands.VerifySession,
      Ordo.Authentication.Commands.SetSessionCorpo
    ],
    to: Ordo.Authentication.Aggregates.Session,
    identity: :session_id
  )
end
