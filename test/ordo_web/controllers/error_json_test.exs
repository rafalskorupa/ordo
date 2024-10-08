defmodule OrdoWeb.ErrorJSONTest do
  use OrdoWeb.ConnCase, async: false

  test "renders 404" do
    assert OrdoWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert OrdoWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
