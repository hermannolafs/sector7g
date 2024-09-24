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
    # TODO spawn with custom incident name
    GenServer.start_link(__MODULE__, "last_incident", name: __MODULE__)
  end

  def reset_counter() do
    GenServer.cast(__MODULE__, :reset)
  end

  def reset_counter(incident_name) do
    GenServer.cast(__MODULE__, {:reset, incident_name})
  end

  def new(incident_name) do
    GenServer.cast(__MODULE__, {:new, incident_name})
  end

  def days_since() do
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
    case Incident.new_incident_changeset(incident, init_date) |> Repo.insert(on_conflict: :nothing) do
      {:error, failed_insert} -> {:error, failed_insert.errors}
      {:ok, _successful_insert} -> {:ok, %{incident: incident, last_incident: init_date}}
    end
  end

  @impl true
  def handle_cast(:reset, state) do
    # TODO conjure useless metrics for this
    {:noreply, state |> Map.put(:last_incident, DateTime.utc_now())}
  end

  @impl true
  def handle_cast({:reset, incident_name}, state) do
    # TODO conjure useless metrics for this
    case Repo.get_by(Incident, name: incident_name) do
      nil -> {:error, :not_found} # TODO better error
      record ->
        record
        |> Incident.changeset(%{incident_date: DateTime.utc_now()})
        |> Repo.update()
    end
    # TODO move this to the case handling I guess
    {:noreply, state |> Map.put(:last_incident, DateTime.utc_now())}
  end


  @impl true
  def handle_call({:new, incident_name}, state) do
    case Incident.new_incident_changeset(incident_name, DateTime.utc_now()) |> Repo.insert() do
      {:ok, _new_incident} -> {:noreply, state} # TODO update state here
      {:error, changeset_error} -> {:error, changeset_error.errors} # TODO differentiate b/w errors
    end
    {:noreply, state}
  end

  @impl true
  def handle_call(:days_since, _from, state) do
    {:reply, calculate_days_since(state.last_incident), state}
  end

  @impl true
  def handle_call({:days_since, _incident_name}, _from, state) do
    # TODO implement me
    {:reply, calculate_days_since(state.last_incident), state}
  end

  # =============================
  # functions
  # =============================
  def calculate_days_since(utc_timestamp) do
    DateTime.utc_now()
    |> DateTime.diff(utc_timestamp, :day)
  end

end
