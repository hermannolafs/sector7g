defmodule Sector7gWeb.IncidentIndexLive do
  use Sector7gWeb, :live_view
  alias Sector7g.Incident

  @topic "incidents"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Sector7g.PubSub, @topic)
    end

    incidents = list_incidents()
    {:ok, assign(socket, incidents: incidents)}
  end

  def handle_info({:incident_updated}, socket) do
    incidents = list_incidents()
    {:noreply, assign(socket, incidents: incidents)}
  end

  defp list_incidents do
    Sector7g.Repo.all(Incident)
  end
end
