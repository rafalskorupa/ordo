defmodule Ordo.AuthenticationTest do
  use Ordo.DataCase, async: false

  alias Ordo.Authentication

  describe "sign_in/2" do
    test "it returns invalid credentials error" do
      assert {:error, :invalid_credentials} = Authentication.sign_in("rafal@skorupa.io", "123123123123")
    end
  end

  describe "register/1" do
    test "creates an account" do
      email = "rafal@skorupa.io"
      password = "123123123123"

      assert :ok == Authentication.register(%{email: email, password: password})
    end
  end
end
