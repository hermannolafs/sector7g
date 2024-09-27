defmodule Sector7g.Incident do
  require Logger
  alias Sector7g.Incident
  use Ecto.Schema
  import Ecto.Changeset

  @topic "incidents"

  schema "incidents" do
    field :last_incident, :date
    field :name, :string
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
    case %Incident{}
    |> changeset(%{name: name, last_incident: date})
    |> Sector7g.Repo.insert(on_conflict: :nothing) # TODO fix that it still pubs to the topic on conflict
    do
      {:ok, _successful_insert} ->
        Phoenix.PubSub.broadcast(Sector7g.PubSub, @topic, {:incident_updated})
        {:ok, %{incident: name, last_incident: date}}
      {:error, failed_insert} -> {:error, failed_insert.errors}
    end
  end

  def get_incident_by_name(name) do
    case Sector7g.Repo.get_by!(Incident, name: name) do
      nil -> {:error, :not_found} # TODO better error
      record -> {:ok, record}
      end
  end

  def reset_incident_counter(name) do
    # TODO we probably should not be doing case within a case
    case Sector7g.Repo.get_by(Incident, name: name) do
      nil -> {:error, :not_found} # TODO better error
      record ->
        case record
        |> Incident.changeset(%{incident_date: DateTime.utc_now()})
        |> Sector7g.Repo.update()
        do
          {:ok, reset_counter} ->
            # TODO look into why this does not seem to propogate to the frontend
            Phoenix.PubSub.broadcast(Sector7g.PubSub, @topic, {:incident_updated})
            {:ok, reset_counter}
        end
    end
  end
end
