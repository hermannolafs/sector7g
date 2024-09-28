defmodule Sector7gWeb.IncidentIndexLive do
  use Sector7gWeb, :live_view
  alias Sector7g.Incident

  @topic "incidents"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Sector7g.PubSub, @topic)
    end

    incidents = list_incidents()
    {:ok, assign(socket, incidents: incidents, show_form: false, new_incident_name: "")}
  end


  # =============================
  # Event handling
  # =============================

  def handle_info({:incident_updated}, socket) do
    incidents = list_incidents()
    {:noreply, assign(socket, incidents: incidents)}
  end

  def handle_event("toggle_form", _, socket) do
    {:noreply, assign(socket, show_form: !socket.assigns.show_form)}
  end

  def handle_event("create_incident", %{"name" => name}, socket) do
    # TODO refactor abstractions to be at the same level like the error thing idk
    case Sector7g.DaysSince.new(name) do
      :ok ->
        {:noreply,
         socket
         |> assign(show_form: false, new_incident_name: "")
         |> put_flash(:info, "Incident created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating incident: #{error_to_string(changeset)}")
         |> assign(new_incident_name: name)}
    end
  end

  def handle_event("update_new_incident_name", %{"value" => value}, socket) do
    {:noreply, assign(socket, new_incident_name: value)}
  end

  defp list_incidents do
    Sector7g.Repo.all(Incident)
  end

  defp error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}#{k}: #{joined_errors}\n"
    end)
  end

  defp incidents_exist?(incidents) do
    length(incidents) > 0
  end
end
