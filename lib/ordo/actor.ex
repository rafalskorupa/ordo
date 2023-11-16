defmodule Ordo.Actor do
  defstruct [:account_id, :user_id, :organisation_id]

  @type t :: %__MODULE__{
          account_id: String.t() | nil,
          user_id: String.t() | nil,
          organisation_id: String.t() | nil
        }

  def build(nil) do
    %__MODULE__{}
  end

  def build(%{account_id: account_id}) do
    %__MODULE__{account_id: account_id}
  end
end
