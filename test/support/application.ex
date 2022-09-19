defmodule Test.Application do
  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Test.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def children do
    [
      {Test.Repo, name: Test.Repo},
      {Redix,
       [
         name: Test.Redix,
         host: redis_host(),
         port: 6379
       ]}
    ]
  end

  defp redis_host do
    if System.get_env("CI") == "true" do
      "redis"
    else
      "localhost"
    end
  end
end
