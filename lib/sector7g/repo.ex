defmodule Sector7g.Repo do
  use Ecto.Repo,
    otp_app: :sector7g,
    adapter: Ecto.Adapters.SQLite3
end
