defmodule Sector7g.Repo.Migrations.AddColumnLongName do
  use Ecto.Migration

  def change do
    alter table(:incidents) do
      add :long_name, :string
    end

  end
end
