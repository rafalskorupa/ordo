defmodule Ordo.Authentication.Password do
  @spec hash_password(String.t()) :: String.t()
  def hash_password(password) do
    Bcrypt.hash_pwd_salt(password)
  end

  @spec password_valid?(String.t(), String.t()) :: boolean()
  def password_valid?(nil, _) do
    Bcrypt.no_user_verify()
    false
  end

  def password_valid?(hashed_password, password) do
    Bcrypt.verify_pass(password, hashed_password)
  end
end
