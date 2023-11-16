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
    [Ordo.Authentication.Commands.CreateAccount],
    to: Ordo.Authentication.Aggregates.Account,
    identity: :account_id
  )
end
