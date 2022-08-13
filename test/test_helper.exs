{:ok, _} = Application.ensure_all_started(:confeature)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Test.Repo, :manual)
