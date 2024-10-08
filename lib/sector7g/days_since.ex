defmodule Sector7g.DaysSince do
  @moduledoc """
  GenServer for keeping track of days since INCIDENT
  """
  # =============================
  # CLIENT
  # =============================
  alias Sector7g.Incident
  use GenServer
  require Logger

  @topic "incidents"

  def start_link([]) do
    # TODO Initializing the db should maybe be in another place
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def reset_counter(incident_name) do
    GenServer.cast(__MODULE__, {:reset, incident_name})
  end

  def new(incident_name) do
    GenServer.call(__MODULE__, {:new, incident_name})
  end

  def get_incident(incident_name) do
    GenServer.call(__MODULE__, {:get, incident_name})
  end

  # =============================
  # Server
  # =============================

  @impl true
  def init([]) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:reset, incident_name}, state) do
    Incident.reset_incident_counter_by_name(incident_name)
    Phoenix.PubSub.broadcast(Sector7g.PubSub, @topic, {:incident_updated})
    {:noreply, state}
  end

  @impl true
  def handle_call({:new, incident_name}, _from, state) do
    case Incident.insert_new_type_of_incident(incident_name) do
      {:ok, _new_incident} ->
        Phoenix.PubSub.broadcast(Sector7g.PubSub, @topic, {:incident_updated})
        {:reply, :ok, state} # TODO update state here
      {:error, _changeset_error} = error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:get, incident_name}, _from, state) do
    {:reply, Incident.get_incident_by_name(incident_name), state}
  end
end
