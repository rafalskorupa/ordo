defmodule OrdoWeb.EmployeeLiveTest do
  use OrdoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ordo.EmployeesFixtures

  @create_attrs %{first_name: "some first_name", last_name: "some last_name"}
  @update_attrs %{first_name: "some updated first_name", last_name: "some updated last_name"}
  @invalid_attrs %{first_name: nil, last_name: nil}

  defp create_employee(_) do
    employee = employee_fixture()
    %{employee: employee}
  end

  describe "Index" do
    setup [:create_employee]

    test "lists all employees", %{conn: conn, employee: employee} do
      {:ok, _index_live, html} = live(conn, ~p"/people")

      assert html =~ "Listing Employees"
      assert html =~ employee.first_name
    end

    test "saves new employee", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/people")

      assert index_live |> element("a", "New Employee") |> render_click() =~
               "New Employee"

      assert_patch(index_live, ~p"/people/new")

      assert index_live
             |> form("#employee-form", employee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#employee-form", employee: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/people")

      html = render(index_live)
      assert html =~ "Employee created successfully"
      assert html =~ "some first_name"
    end

    test "updates employee in listing", %{conn: conn, employee: employee} do
      {:ok, index_live, _html} = live(conn, ~p"/people")

      assert index_live |> element("#employees-#{employee.id} a", "Edit") |> render_click() =~
               "Edit Employee"

      assert_patch(index_live, ~p"/people/#{employee}/edit")

      assert index_live
             |> form("#employee-form", employee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#employee-form", employee: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/people")

      html = render(index_live)
      assert html =~ "Employee updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes employee in listing", %{conn: conn, employee: employee} do
      {:ok, index_live, _html} = live(conn, ~p"/people")

      assert index_live |> element("#employees-#{employee.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#employees-#{employee.id}")
    end
  end

  describe "Show" do
    setup [:create_employee]

    test "displays employee", %{conn: conn, employee: employee} do
      {:ok, _show_live, html} = live(conn, ~p"/people/#{employee}")

      assert html =~ "Show Employee"
      assert html =~ employee.first_name
    end

    test "updates employee within modal", %{conn: conn, employee: employee} do
      {:ok, show_live, _html} = live(conn, ~p"/people/#{employee}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Employee"

      assert_patch(show_live, ~p"/people/#{employee}/show/edit")

      assert show_live
             |> form("#employee-form", employee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#employee-form", employee: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/people/#{employee}")

      html = render(show_live)
      assert html =~ "Employee updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
