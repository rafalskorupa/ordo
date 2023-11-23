defmodule Ordo.Nasa.Program do
  @moduledoc """
  Module responsible for building Ordo.Nasa.Program structure that allows to easily kept
  a data related to the program and enforcing some basic constraints
  """

  defstruct [:mass, :route]

  alias Ordo.Nasa.Program
  alias Ordo.Nasa.Types

  @type action :: Ordo.Nasa.Program.Stage.t()
  @type flight_route :: list(action())

  @type stage_tuple :: Ordo.Nasa.Program.Stage.stage_tuple()

  @type t :: %__MODULE__{
          mass: Types.mass(),
          route: flight_route()
        }

  @type build_errors :: {:error, {:mass | :route, String.t()}}

  @doc """
  Build Ordo.Nasa Program representation
  """
  @spec build(Types.mass(), flight_route()) :: {:ok, t()} | build_errors()
  def build(ship_mass, flight_route) do
    with {:mass_positive, true} <- {:mass_positive, ship_mass > 0},
         {:route, {:ok, route}} <- {:route, build_route(flight_route)} do
      {:ok,
       %Ordo.Nasa.Program{
         mass: ship_mass,
         route: route
       }}
    else
      {:mass_positive, false} -> {:error, {:mass, "must be positive"}}
      {:route, {:error, error}} -> {:error, {:route, error}}
    end
  end

  # 1. Flight route shouldn't have two consecutive landings/launches - they should be alternating
  # 2. inspecting actions in error message is not a best idea
  @spec build_route(list(stage_tuple())) :: {:ok, list(action())} | build_errors()
  defp build_route(actions) when is_list(actions) do
    actions
    |> Enum.reject(&Program.Stage.action_valid?/1)
    |> case do
      [] ->
        {:ok, Enum.map(actions, &Program.Stage.from_tuple!/1)}

      invalid_actions ->
        {:error, "#{inspect(invalid_actions)} are invalid actions"}
    end
  end

  defp build_route(_), do: {:error, "must be a list"}
end
