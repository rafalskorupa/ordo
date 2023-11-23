defmodule Ordo.Nasa.Program.Stage do
  @moduledoc """
  Module to represent Stage data structure.

  Using tuple to represent actions is the simplest and good-enough solution,
  but tying its domain representation in tuple means that any change in the future
  might be difficult.

  F.e. in case Stage should contain information about the place of launch/landing -
  adding additional elements to tuple wouldn't be clean solutions.

  Using appropriate library (f.e. Ecto and embedded_schema) would make it simpler,
  but I decided to keep it external-dependencies free.
  """

  defstruct [:action, :gravity]

  defmodule InvalidTupleError do
    defexception [:message, :tuple]
  end

  alias Ordo.Nasa.Types

  @stage_type ~w(launch land)a

  @type stage_tuple :: {Types.stage_type(), Types.gravity()}

  @type t :: %__MODULE__{
          action: Types.stage_type(),
          gravity: Types.gravity()
        }

  @doc """
  Returns boolean whether given tuple is valid actions

  Currently gravity must be the second element in tuple, but in the future it could
  be name alias f.e. Mars:

  iex |> Ordo.Nasa.Program.Stage.valid_tuple?({:launch, "Mars"})
  false

  iex |> Ordo.Nasa.Program.Stage.valid_tuple?({:launch, 0})
  false

  iex |> Ordo.Nasa.Program.Stage.valid_tuple?({:launch, 9.807})
  true

  iex |> Ordo.Nasa.Program.Stage.valid_tuple?({:land, 4)
  true
  """

  @spec action_valid?(stage_tuple()) :: boolean()
  def action_valid?({_, gravity}) when not is_number(gravity), do: false
  def action_valid?({_, gravity}) when gravity <= 0, do: false
  def action_valid?({type, _}) when type in @stage_type, do: true
  def action_valid?(_), do: false

  @doc """
  Builds Stage struct from tuple

  iex |> Ordo.Nasa.Program.Stage.from_tuple!({:launch, 3})
  %Ordo.Nasa.Program.Stage{action: :launch, gravity: 3}

  """
  def from_tuple!({action, gravity} = tuple) do
    if action_valid?({action, gravity}) do
      %__MODULE__{action: action, gravity: gravity}
    else
      raise InvalidTupleError, tuple: tuple
    end
  end

  def from_tuple!(tuple), do: raise(InvalidTupleError, tuple: tuple)

  @spec to_tuple(t()) :: stage_tuple()
  def to_tuple(%__MODULE__{action: action, gravity: gravity}) do
    {action, gravity}
  end
end
