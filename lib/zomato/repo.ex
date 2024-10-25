defmodule Zomato.Repo do
  use Ecto.Repo,
    otp_app: :zomato,
    adapter: Ecto.Adapters.Postgres
end
