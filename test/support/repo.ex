defmodule Test.Repo do
  use Ecto.Repo,
    otp_app: :confeature,
    adapter: Ecto.Adapters.Postgres
end
