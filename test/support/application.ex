defmodule Test.Application do
  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Test.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def children do
    [
      {Test.Repo, name: Test.Repo},
      {Redix, [
        name: Test.Redix,
        host: "localhost",
        port: 6379
      ]}
    ]
  end
end
