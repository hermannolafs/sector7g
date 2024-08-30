# lib/my_app_web/live/incident_counter_live.ex
defmodule Sector7gWeb.DaysSinceLive do
  use Sector7gWeb, :live_view

  def mount(_params, _session, socket) do
    days = Sector7g.DaysSince.days_since()
    {:ok, assign(socket, days: days)}
  end

  def handle_event("reset", _params, socket) do
    Sector7g.DaysSince.reset_counter()
    days = Sector7g.DaysSince.days_since()
    {:noreply, assign(socket, days: days)}
  end
end
