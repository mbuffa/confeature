defmodule Test.Repo do
  use Ecto.Repo,
    otp_app: :confeature,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    if System.get_env("CI") == "true" do
      url = "ecto://postgres:postgres@postgres:5432/confeature_test"
      {:ok, Keyword.put(config, :url, url)}
    else
      {:ok, config}
    end

  end
end
