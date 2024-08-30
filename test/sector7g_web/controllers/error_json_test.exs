defmodule Sector7gWeb.ErrorJSONTest do
  use Sector7gWeb.ConnCase, async: true

  test "renders 404" do
    assert Sector7gWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Sector7gWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
