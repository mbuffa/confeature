defmodule Test.Repo do
  use Ecto.Repo,
    otp_app: :confeature,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    if System.get_env("CI") == "true" do
      url = "ecto://postgres:postgres@postgres:5432/confeature_test"
      config =
        config
        |> Keyword.put(:url, url)
        |> Keyword.delete(:hostname)
        |> Keyword.delete(:username)
        |> Keyword.delete(:password)
        |> Keyword.delete(:database)
        |> Keyword.delete(:port)
        |> Keyword.put(:timeout, 60000)

      IO.inspect {:debug, config}
      {:ok, config}
    else
      {:ok, config}
    end

  end
end
