defmodule OrdoWeb.OrganisationLiveTest do
  use OrdoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ordo.OrganisationsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_organisation(_) do
    organisation = organisation_fixture()
    %{organisation: organisation}
  end

  describe "Index" do
    setup [:create_organisation]

    test "lists all organisations", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/organisations")

      assert html =~ "Listing Organisations"
    end

    test "saves new organisation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/organisations")

      assert index_live |> element("a", "New Organisation") |> render_click() =~
               "New Organisation"

      assert_patch(index_live, ~p"/organisations/new")

      assert index_live
             |> form("#organisation-form", organisation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#organisation-form", organisation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/organisations")

      html = render(index_live)
      assert html =~ "Organisation created successfully"
    end

    test "updates organisation in listing", %{conn: conn, organisation: organisation} do
      {:ok, index_live, _html} = live(conn, ~p"/organisations")

      assert index_live
             |> element("#organisations-#{organisation.id} a", "Edit")
             |> render_click() =~
               "Edit Organisation"

      assert_patch(index_live, ~p"/organisations/#{organisation}/edit")

      assert index_live
             |> form("#organisation-form", organisation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#organisation-form", organisation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/organisations")

      html = render(index_live)
      assert html =~ "Organisation updated successfully"
    end

    test "deletes organisation in listing", %{conn: conn, organisation: organisation} do
      {:ok, index_live, _html} = live(conn, ~p"/organisations")

      assert index_live
             |> element("#organisations-#{organisation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#organisations-#{organisation.id}")
    end
  end

  describe "Show" do
    setup [:create_organisation]

    test "displays organisation", %{conn: conn, organisation: organisation} do
      {:ok, _show_live, html} = live(conn, ~p"/organisations/#{organisation}")

      assert html =~ "Show Organisation"
    end

    test "updates organisation within modal", %{conn: conn, organisation: organisation} do
      {:ok, show_live, _html} = live(conn, ~p"/organisations/#{organisation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Organisation"

      assert_patch(show_live, ~p"/organisations/#{organisation}/show/edit")

      assert show_live
             |> form("#organisation-form", organisation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#organisation-form", organisation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/organisations/#{organisation}")

      html = render(show_live)
      assert html =~ "Organisation updated successfully"
    end
  end
end
