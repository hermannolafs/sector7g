defmodule Sector7g.Incident do
  alias Sector7g.Incident
  use Ecto.Schema
  import Ecto.Changeset

  schema "incidents" do
    field :last_incident, :date
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:name, :last_incident])
    |> validate_required([:name, :last_incident])
    |> unique_constraint(:name)
  end

  # TODO make it default in a more ecto way I guess
  def new_incident_changeset(name, date \\ DateTime.utc_now()) do
    %Incident{}
    |> changeset(%{name: name, last_incident: date})
  end
end
