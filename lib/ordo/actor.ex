defmodule Ordo.Actor do
  defstruct [:account, :user, :organisation]

  @type t :: %__MODULE__{
          account: %{id: String.t(), email: String.t()} | nil,
          user: nil,
          organisation: nil
        }

  def build(nil) do
    %__MODULE__{}
  end

  def build(%{account: account}) do
    %__MODULE__{account: account}
  end
end
