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

  # TODO add rm functionality
  def insert_new_type_of_incident(name) do
    {:ok, important_moment, _offset} = DateTime.from_iso8601("2019-07-23T01:27:00+00:00")
    case %Incident{}
    |> changeset(%{name: name, last_incident: important_moment})
    |> Sector7g.Repo.insert(on_conflict: :nothing) # TODO fix that it still pubs to the topic on conflict
    do
      {:ok, _successful_insert} -> {:ok, %{incident: name}}
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
