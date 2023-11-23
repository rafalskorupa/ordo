defmodule Ordo.Nasa do
  @moduledoc """
  Documentation for `Ordo.Nasa`.


  """

  alias Ordo.Nasa.Types

  @doc """
  Hello world.

  ## Examples

      iex> Ordo.Nasa.hello()
      nil

  """
  def hello do
    nil
  end

  @doc """
  This is the entry point of application as described in document.

  It takes 2 arguments. F
  First one is the flight ship mass, and second is an array of 2 element tuples,
  with the first element being land or launch directive,
  and second element is the target planet gravity.
  """
  @spec call(Types.mass(), list({Types.stage_type(), Types.gravity()})) ::
          {:ok, Types.fuel()} | {:error, any()}
  def call(ship_mass, flight_route) do
    with {:ok, program} <- Ordo.Nasa.Program.build(ship_mass, flight_route) do
      {:ok, Ordo.Nasa.Fuel.calculate_fuel_required(program)}
    end
  end
end
