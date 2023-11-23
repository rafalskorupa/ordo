defmodule Ordo.Nasa.FuelTest do
  use ExUnit.Case

  alias Ordo.Nasa
  doctest Ordo.Nasa.Fuel


  describe "calculate_fuel_required/1" do
    test "it returns fuel required for given naval program" do
      program = %Nasa.Program{
        mass: 28_801,
        route: [
          %Nasa.Program.Stage{action: :launch, gravity: 9.807},
          %Nasa.Program.Stage{action: :land, gravity: 1.62},
          %Nasa.Program.Stage{action: :launch, gravity: 1.62},
          %Nasa.Program.Stage{action: :land, gravity: 9.807}
        ]
      }

      assert Nasa.Fuel.calculate_fuel_required(program) == 51_898.0
    end
  end
end
