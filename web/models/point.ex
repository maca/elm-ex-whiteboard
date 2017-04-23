defmodule ElmExWhiteboard.Point do
  use ElmExWhiteboard.Web, :model

  @public_fields [:id, :x, :y, :line_id, :color,
                  :width, :session_id, :client_id]

  @primary_key {:id, :integer, []}

  schema "points" do
    field :x,          :integer
    field :y,          :integer
    field :line_id,    :integer
    field :color,      :string
    field :width,      :string
    field :session_id, :string
    field :client_id,  :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, @public_fields)
      |> validate_required(@public_fields)
  end

  def public_fields, do: @public_fields
end
