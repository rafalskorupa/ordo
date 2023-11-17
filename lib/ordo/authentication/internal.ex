defmodule Ordo.Authentication.Internal do
  @moduledoc """
  Internal API for Authentication Module
  """

  def verify_account_has_access_to_corpo(%{account_id: account_id, corpo_id: corpo_id})
      when is_binary(account_id) and is_binary(corpo_id) do
    case Ordo.Repo.get_by(Ordo.People.Projections.Employee,
           account_id: account_id,
           corpo_id: corpo_id
         ) do
      nil -> {:error, :invalid_corpo_id}
      %{} -> :ok
    end
  end
end
