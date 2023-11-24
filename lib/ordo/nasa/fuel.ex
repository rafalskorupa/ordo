defmodule Ordo.Nasa.Fuel do
  alias Ordo.Nasa.Program

  # Those values are separated from method definition - different ships
  # may have impact on those values, so there is a big chance they are
  # going to become variables in next steps
  @launch_consumption_rate 0.042
  @launch_consumption_base -33

  @landing_consumption_rate 0.033
  @landing_consumption_base -42

  alias Ordo.Nasa.Types

  @type action :: :launch | :gravity

  @doc """
    Returns fuel required for given Space program
  """
  @spec calculate_fuel_required(Program.t()) :: Types.fuel()
  def calculate_fuel_required(%Program{route: []}), do: 0

  def calculate_fuel_required(%Program{mass: mass, route: route}) do
    route
    |> Enum.reverse()
    |> Enum.reduce(0, fn current_action, current_fuel ->
      action_cost = calculate_consumption(mass + current_fuel, current_action)

      current_fuel + action_cost
    end)
  end

  @doc """
    Returns fuel consumption for given action

    iex> Nasa.Fuel.calculate_consumption(28801, %Nasa.Program.Stage{action: :launch, gravity: 9.807})
    19772.0


    iex> Nasa.Fuel.calculate_consumption(28801, %Nasa.Program.Stage{action: :land, gravity: 9.807})
    13447.0
  """

  def calculate_consumption(mass, %Program.Stage{action: :launch, gravity: gravity}) do
    calculate_accumulated_consumption(mass, fn current_mass ->
      launch_consumption(current_mass, gravity)
    end)
  end

  def calculate_consumption(mass, %Program.Stage{action: :land, gravity: gravity}) do
    calculate_accumulated_consumption(mass, fn current_mass ->
      landing_consumption(current_mass, gravity)
    end)
  end

  @doc """
    Implements generalized formula for fuel calculations.

    (mass * gravity * rate + base) rounded down

    iex> Nasa.Fuel.consumption(9278, 9.807, 0.033, -42)
    2960.0

    iex> Nasa.Fuel.consumption(2960, 9.807, 0.033, -42)
    915.0

    iex> Nasa.Fuel.consumption(40, 9.807, 0.033, -42)
    0
  """
  @spec consumption(Types.mass(), Types.gravity(), number(), number()) :: Types.fuel()
  def consumption(mass, gravity, rate, base) do
    case mass * gravity * rate + base do
      number when number > 0 ->
        Float.floor(number)

      _ ->
        0
    end
  end

  @spec launch_consumption(Types.mass(), Types.gravity()) :: Types.fuel()
  defp launch_consumption(mass, gravity) do
    consumption(
      mass,
      gravity,
      @launch_consumption_rate,
      @launch_consumption_base
    )
  end

  @spec landing_consumption(Types.mass(), Types.gravity()) :: Types.fuel()
  defp landing_consumption(mass, gravity) do
    consumption(
      mass,
      gravity,
      @landing_consumption_rate,
      @landing_consumption_base
    )
  end

  @spec calculate_accumulated_consumption(Types.mass(), (Types.mass() -> Types.fuel())) ::
          Types.fuel()
  defp calculate_accumulated_consumption(initial_mass, consumption_fn) do
    initial_mass
    |> Stream.unfold(fn
      mass when mass > 0 ->
        consumption = consumption_fn.(mass)

        {consumption, consumption}

      _ ->
        nil
    end)
    |> Enum.sum()
  end
end
