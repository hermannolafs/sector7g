defmodule Sector7g.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents) do
      add :last_incident, :utc_datetime
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:incidents, [:name])

  end
end
