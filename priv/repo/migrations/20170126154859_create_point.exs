defmodule ElmExWhiteboard.Repo.Migrations.CreatePoint do
  use Ecto.Migration

  def change do
    create table(:points, primary_key: false) do
      add :id,         :integer
      add :x,          :integer
      add :y,          :integer
      add :line_id,    :integer
      add :color,      :string
      add :width,      :string
      add :session_id, :string
      add :client_id,  :string

      timestamps()
    end

    create index(:points, [:session_id])
  end
end
