defmodule Ordo.Actor do
  defstruct [:account]

  @type t :: %__MODULE__{
          account: %{id: String.t(), email: String.t()} | nil
        }

  def build(nil) do
    %__MODULE__{}
  end

  def build(%{account: account}) do
    %__MODULE__{account: account}
  end

  def serialize(%__MODULE__{account: nil}) do
    %{account_id: nil}
  end

  def serialize(%__MODULE__{account: %{id: account_id}}) do
    %{account_id: account_id}
  end
end
