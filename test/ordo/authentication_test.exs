defmodule Ordo.AuthenticationTest do
  use Ordo.DataCase, async: false

  alias Ordo.Authentication
  alias Ordo.Repo
  alias Ordo.Authentication.Projections.Account

  @email "rafal@skorupa.io"
  @password "123123123123"

  defp create_account(_ \\ %{}) do
    Authentication.register(%{email: @email, password: @password})
    account = Repo.get_by(Account, email: @email)
    actor = Ordo.Actor.build(%{account: account})

    %{account: account, actor: actor}
  end

  describe "sign_in/2" do
    test "it returns actor based on account" do
      %{actor: actor} = create_account()

      assert {:ok, actor} == Authentication.sign_in("rafal@skorupa.io", "123123123123")
    end

    test "it returns invalid credentials error" do
      assert {:error, :invalid_credentials} =
               Authentication.sign_in("rafal@skorupa.io", "123123123123")
    end
  end

  describe "register/1" do
    test "creates an account" do
      assert :ok == Authentication.register(%{email: @email, password: @password})
      assert Repo.get_by(Account, email: @email)
    end

    test "enforce uniquness of email" do
      assert %{account: %{id: account_id}} = create_account()
      assert {:error, changeset} = Authentication.register(%{email: @email, password: @password})

      assert errors_on(changeset) == %{email: ["has already been taken"]}
      assert [%{id: ^account_id}] = Repo.all(Account)
    end

    test "enforce minimal length of password" do
      assert {:error, changeset} = Authentication.register(%{email: @email, password: "123"})
      assert errors_on(changeset) == %{password: ["should be at least 12 character(s)"]}
      refute Repo.get_by(Account, email: @email)
    end
  end

  describe "update_password/2" do
    setup [:create_account]

    test "it updates password", %{account: account, actor: actor} do
      new_password = "new-password-123"

      assert :ok ==
               Authentication.update_password(actor, %{
                 old_password: @password,
                 new_password: new_password
               })

      assert Ordo.Authentication.Password.password_valid?(
               Repo.reload(account).hashed_password,
               new_password
             )
    end

    test "enforce minimal length of password", %{account: account, actor: actor} do
      assert {:error, changeset} =
               Authentication.update_password(actor, %{
                 old_password: @password,
                 new_password: "123"
               })

      assert errors_on(changeset) == %{new_password: ["should be at least 12 character(s)"]}

      assert Ordo.Authentication.Password.password_valid?(
               Repo.reload(account).hashed_password,
               @password
             )

      refute Ordo.Authentication.Password.password_valid?(
               Repo.reload(account).hashed_password,
               "123"
             )
    end
  end
end
