defmodule Autocontext.Repo do
  use Ecto.Repo,
    otp_app: :autocontext,
    adapter: Ecto.Adapters.Postgres
end
