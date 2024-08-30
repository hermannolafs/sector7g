defmodule Sector7g.DaysSince do
  @moduledoc """
  GenServer for keeping track of days since
  """

  # =============================
  # CLIENT
  # =============================
  require Logger
  use GenServer

  def start_link(incident \\ "Incident") do
    GenServer.start_link(__MODULE__, incident, name: __MODULE__)
  end

  def reset_counter() do
    GenServer.cast(__MODULE__, :reset)
  end

  def days_since() do
    GenServer.call(__MODULE__, :days_since)
  end

  # =============================
  # Server
  # =============================

  def init(incident \\ "Incident") do
    {:ok, init_date, 0} = DateTime.from_iso8601("2019-07-23T01:27:00+00:00")
    {:ok, %{incident: incident, last_incident: init_date}}
  end

  def handle_cast(:reset, state) do
    {:noreply, state |> Map.put(:last_incident, DateTime.utc_now())}
  end

  def handle_call(:days_since, _from, state) do
    {:reply, calculate_days_since(state.last_incident), state}
  end

  def calculate_days_since(utc_timestamp) do
    DateTime.utc_now()
    |> DateTime.diff(utc_timestamp, :day)
  end

end
