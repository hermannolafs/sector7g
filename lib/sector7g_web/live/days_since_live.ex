defmodule Sector7gWeb.DaysSinceLive do
  alias Sector7g.Incident
  use Sector7gWeb, :live_view
  require Logger

  def mount(%{"name" => name}, _session, socket) do
    record = Incident.get_incident_by_name(name)
    {:ok, assign(socket, incident: record, days: Incident.calculate_days_since_timestamp(record.last_incident))}
  end

  def handle_event("reset", _params, socket) do
    # TODO this should maybe be more clever
    %{assigns: %{incident: incident}} = socket
    Sector7g.DaysSince.reset_counter(incident.name)
    {:noreply, assign(socket, days: 0)}
  end
end
