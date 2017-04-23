defmodule ElmExWhiteboard.PointTest do
  use ElmExWhiteboard.ModelCase

  alias ElmExWhiteboard.Point

  @valid_attrs %{client_id: "some content", color: "some content", id: 42, line_id: 42, width: "some content", x: 42, y: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Point.changeset(%Point{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Point.changeset(%Point{}, @invalid_attrs)
    refute changeset.valid?
  end
end
