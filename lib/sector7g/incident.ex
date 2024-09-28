defmodule Sector7g.Incident do
  require Logger
  alias Sector7g.Incident
  use Ecto.Schema
  import Ecto.Changeset

  schema "incidents" do
    field :last_incident, :utc_datetime
    field :name, :string
    field :long_name, :string
    # TODO add field for full_name or something more long form

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:name, :last_incident])
    |> validate_required([:name, :last_incident])
    |> unique_constraint(:name)
  end

  # =============================
  # doobydoobydoo
  # =============================

  # TODO make it default in a more ecto way I guess
  def new_incident_changeset(name, date \\ DateTime.utc_now()) do
    %Incident{}
    |> changeset(%{name: name, last_incident: date})
  end

  # TODO add rm functionality
  def insert_new_type_of_incident(name, date \\ DateTime.utc_now()) do
    Logger.debug(name)
    case %Incident{}
    |> changeset(%{name: name, last_incident: date})
    |> Sector7g.Repo.insert(on_conflict: :nothing) # TODO fix that it still pubs to the topic on conflict
    do
      {:ok, _successful_insert} -> {:ok, %{incident: name, last_incident: date}}
      {:error, failed_insert} -> {:error, failed_insert.errors}
    end
  end

  def get_incident_by_name(name) do
    # This helper function is meant to ensure Ecto.NoResultsError being thrown
    Sector7g.Repo.get_by!(Incident, name: name)
  end

  def reset_incident_counter_by_name(name) do
    case Incident.get_incident_by_name(name)
    |> Sector7g.Incident.changeset(%{last_incident: DateTime.utc_now()})
    |> Sector7g.Repo.update() do
      {:ok, reset_counter} -> {:ok, reset_counter}
      {:error, error_changeset} -> {:error, error_changeset.errors}
    end
  end

  def calculate_days_since_timestamp(utc_timestamp) do
    DateTime.utc_now()
    |> DateTime.diff(utc_timestamp, :day)
  end
end
