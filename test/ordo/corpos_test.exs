defmodule Ordo.CorposTest do
  use Ordo.DataCase, async: false

  import Ordo.AuthFixtures

  alias Ordo.Corpos
  alias Ordo.Repo

  alias Ordo.People.Projections.Employee

  describe "create_corpo/2" do
    setup do
      create_account()
    end

    test "it creates corpo with employee record", %{actor: actor} do
      assert {:ok, corpo} = Corpos.create_corpo(actor, %{name: "Corpo Name"})
      assert corpo.name == "Corpo Name"
      assert Repo.get_by!(Employee, account_id: actor.account.id, corpo_id: corpo.id)
    end

    test "it validates name", %{actor: actor} do
      assert {:error, changeset} = Corpos.create_corpo(actor, %{name: ""})
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end
  end
end
