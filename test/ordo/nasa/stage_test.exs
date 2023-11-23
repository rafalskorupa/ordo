defmodule Ordo.Nasa.Program.StageTest do
  use ExUnit.Case

  doctest Ordo.Nasa.Program.Stage
  alias Ordo.Nasa

  describe "from_tuple!/1" do
    test "raise error if tuple is invalid" do
      tuple = {:manouver, 4}

      exception =
        assert_raise(Nasa.Program.Stage.InvalidTupleError, fn ->
          Nasa.Program.Stage.from_tuple!(tuple)
        end)

      assert exception.tuple == tuple
    end
  end
end
