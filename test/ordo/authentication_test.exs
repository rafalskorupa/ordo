defmodule Ordo.AuthenticationTest do
  use Ordo.DataCase, async: false

  alias Ordo.Authentication
  alias Ordo.Repo
  alias Ordo.Authentication.Projections.Account
  alias Ordo.Authentication.Projections.Session

  @email "rafal@skorupa.io"
  @password "123123123123"

  import Ordo.AuthFixtures

  describe "create_session/1" do
    test "it creates session for actor" do
      %{account: %{id: account_id}, actor: actor} = create_account()

      assert {:ok, session_id} = Authentication.create_session(actor)

      assert %{id: ^session_id, account_id: ^account_id, corpo_id: nil, employee_id: nil} =
               Repo.get(Session, session_id)
    end

    test "it creates session for actor with company" do
      %{account: %{id: account_id}, actor: actor} = create_account()
      {:ok, corpo} = Ordo.Corpos.create_corpo(actor, %{name: "Name"})
      actor = %Ordo.Actor{actor | corpo: corpo}

      assert {:ok, session_id} = Authentication.create_session(actor)
      assert %Session{} = session = Repo.get(Session, session_id)

      assert session.account_id == account_id
      assert session.corpo_id == corpo.id
      assert session.employee_id
    end

    test "it returns invalid_account_id error" do
      account_id = Ecto.UUID.generate()

      assert {:error, :invalid_account_id} =
               Authentication.create_session(%Ordo.Actor{account: %{id: account_id}})
    end
  end

  describe "get_session/1" do
    test "it returns session" do
      %{account: %{id: account_id}, actor: actor} = create_account()
      {:ok, session_id} = Authentication.create_session(actor)
      {:ok, %{id: corpo_id}} = Ordo.Corpos.create_corpo(actor, %{name: "Name"})

      assert %{account_id: ^account_id, corpo_id: nil} = Authentication.get_session(session_id)

      :ok = Authentication.set_active_corpo_id(session_id, corpo_id)

      assert %{account_id: ^account_id, corpo_id: ^corpo_id} =
               Authentication.get_session(session_id)
    end

    test "it returns nil if session doesn't exist" do
      refute Authentication.get_session(Ecto.UUID.generate())
    end
  end

  describe "get_actor_by_session_id/1" do
    test "it returns actor" do
      %{account: %{id: account_id}, actor: actor} = create_account()
      {:ok, session_id} = Authentication.create_session(actor)
      {:ok, %{id: corpo_id}} = Ordo.Corpos.create_corpo(actor, %{name: "Name"})

      assert {:ok, %Ordo.Actor{account: %{id: ^account_id}, corpo: nil}} =
               Authentication.get_actor_by_session_id(session_id)

      :ok = Authentication.set_active_corpo_id(session_id, corpo_id)

      assert {:ok, %Ordo.Actor{account: %{id: ^account_id}, corpo: %{id: ^corpo_id}}} =
               Authentication.get_actor_by_session_id(session_id)
    end

    test "it returns error if session doesn't exist" do
      assert {:error, :session_not_found} ==
               Authentication.get_actor_by_session_id(Ecto.UUID.generate())
    end
  end

  describe "set_active_corpo_id/2" do
    test "it updates session with corpo_id" do
      %{account: %{id: account_id}, actor: actor} = create_account()
      {:ok, session_id} = Authentication.create_session(actor)
      {:ok, %{id: corpo_id}} = Ordo.Corpos.create_corpo(actor, %{name: "Name"})

      assert :ok = Authentication.set_active_corpo_id(session_id, corpo_id)
      assert %{account_id: ^account_id, corpo_id: ^corpo_id} = Repo.get!(Session, session_id)
    end

    test "it doesn't update session if account doesn't have access to corpo" do
      %{actor: actor} = create_account()
      {:ok, session_id} = Authentication.create_session(actor)

      corpo_id = Ecto.UUID.generate()

      assert {:error, :invalid_corpo_id} =
               Authentication.set_active_corpo_id(session_id, corpo_id)
    end

    test "it doesn't update session if session doesn't exist" do
      assert {:error, :session_invalid} =
               Authentication.set_active_corpo_id(Ecto.UUID.generate(), Ecto.UUID.generate())
    end
  end

  describe "verify_session/1" do
    test "it returns :ok if session is valid" do
      %{actor: actor} = create_account()
      assert {:ok, session_id} = Authentication.create_session(actor)

      assert :ok == Authentication.verify_session(session_id)
    end

    test "it returns :error if session is invalid" do
      assert {:error, :session_invalid} == Authentication.verify_session(Ecto.UUID.generate())
    end
  end

  describe "sign_in/2" do
    test "it returns actor based on account" do
      %{actor: actor} = create_account(%{email: "rafal@skorupa.io", password: "123123123123"})

      assert {:ok, actor} ==
               Authentication.sign_in(%{email: "rafal@skorupa.io", password: "123123123123"})
    end

    test "it returns invalid credentials error" do
      assert {:error, :invalid_credentials} =
               Authentication.sign_in(%{email: "rafal@skorupa.io", password: "123123123123"})
    end
  end

  describe "register/1" do
    test "creates an account" do
      create_account(%{email: @email, password: @password})
      assert Repo.get_by(Account, email: @email)
    end

    test "enforce uniquness of email" do
      assert %{account: %{id: account_id}} = create_account(%{email: @email, password: @password})
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
    setup do
      create_account(%{email: @email, password: @password})
    end

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
