defmodule Sector7g.DaysSince do
  @moduledoc """
  GenServer for keeping track of days since INCIDENT
  """
  # =============================
  # CLIENT
  # =============================
  alias Sector7g.Incident
  alias Sector7g.Repo
  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, "last_incident", name: __MODULE__)
  end
  def reset_counter(incident_name) do
    GenServer.cast(__MODULE__, {:reset, incident_name})
  end

  def new(incident_name) do
    GenServer.cast(__MODULE__, {:new, incident_name})
  end

  def days_since() do
    # TODO not sure we need this anymore
    GenServer.call(__MODULE__, :days_since)
  end

  def days_since(incident_name) do
    GenServer.call(__MODULE__, {:days_since, incident_name})
  end

  # =============================
  # Server
  # =============================

  @impl true
  def init(incident) do
    {:ok, init_date, 0} = DateTime.from_iso8601("2019-07-23T01:27:00+00:00")
    Incident.insert_new_type_of_incident(incident, init_date)
  end

  @impl true
  def handle_cast({:reset, incident_name}, state) do
    Incident.reset_incident_counter_by_name(incident_name)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:new, incident_name}, state) do
    case Incident.new_incident_changeset(incident_name, DateTime.utc_now()) |> Repo.insert() do
      {:ok, _new_incident} -> {:noreply, state} # TODO update state here
      {:error, changeset_error} -> {:error, changeset_error.errors} # TODO differentiate b/w errors
    end
  end

  @impl true
  def handle_call({:days_since, incident_name}, _from, state) do
    incident = Incident.get_incident_by_name(incident_name)
    {:reply, incident.last_incident |> Incident.calculate_days_since_timestamp(), state}
  end
end
