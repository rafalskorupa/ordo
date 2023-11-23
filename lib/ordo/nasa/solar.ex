defmodule Ordo.Nasa.Solar do
  @moduledoc """
  Some constants useful for generating flight routes.
  Not used in current implementation, but might be useful in future (or removed)

  It allows to easily define flights, f.e.:
  Ordo.Nasa.call(28_801, [
                 Earth.launch(),
                 Moon.landing(),
                 Moon.launch(),
                 Earth.landing()
               ]
  """

  defmodule Earth do
    @moduledoc false

    def name, do: "Earth"
    def gravity, do: 9.807

    def landing, do: {:land, gravity()}
    def launch, do: {:launch, gravity()}
  end

  defmodule Mars do
    @moduledoc false

    def name, do: "Mars"
    def gravity, do: 3.711

    def landing, do: {:land, gravity()}
    def launch, do: {:launch, gravity()}
  end

  defmodule Moon do
    @moduledoc false

    def name, do: "Moon"
    def gravity, do: 1.62

    def landing, do: {:land, gravity()}
    def launch, do: {:launch, gravity()}
  end

  defmodule Venus do
    @moduledoc false

    def name, do: "Venus"
    def gravity, do: 8.87

    def landing, do: {:land, gravity()}
    def launch, do: {:launch, gravity()}
  end
end
