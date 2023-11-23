defmodule Ordo.NasaTest do
  use ExUnit.Case
  doctest Ordo.Nasa

  test "greets the space and space is dark and empty void..." do
    assert Ordo.Nasa.hello() == nil
  end

  alias Ordo.Nasa.Solar.{Earth, Moon, Mars, Venus}

  describe "calculate_fuel_required" do
    test "Apollo 11 program" do
      assert {:ok, 51_898.0} ==
               Ordo.Nasa.call(28_801, [
                 Earth.launch(),
                 Moon.landing(),
                 Moon.launch(),
                 Earth.landing()
               ])
    end

    test "Mission on Mars" do
      assert {:ok, 33_388} ==
               Ordo.Nasa.call(14_606, [
                 {:launch, 9.807},
                 {:land, 3.711},
                 {:launch, 3.711},
                 {:land, 9.807}
               ])
    end

    test "Passenger ship" do
      assert {:ok, 212_161.0} =
               Ordo.Nasa.call(75_432, [
                 {:launch, 9.807},
                 {:land, 1.62},
                 {:launch, 1.62},
                 {:land, 3.711},
                 {:launch, 3.711},
                 {:land, 9.807}
               ])
    end

    test "From Venus to Mars" do
      assert {:ok, 100_459.0} =
               Ordo.Nasa.call(50_000, [
                 Venus.launch(),
                 Mars.landing(),
                 Mars.launch(),
                 Venus.landing()
               ])
    end

    test "staying in the base is free" do
      assert {:ok, 0} = Ordo.Nasa.call(100_000, [])
    end

    test "when ship mass is invalid" do
      assert {:error, {:mass, "must be positive"}} = Ordo.Nasa.call(-2, [])
    end

    test "when flight route is invalid" do
      assert {:error, {:route, "must be a list"}} =
               Ordo.Nasa.call(75_432, {
                 {:launch, 9.807},
                 {:land, 1.62}
               })

      assert {:error, {:route, "[manouver: 9.807, land: -2] are invalid actions"}} =
               Ordo.Nasa.call(75_432, [
                 {:launch, 9.807},
                 {:manouver, 9.807},
                 {:land, -2}
               ])
    end
  end
end
