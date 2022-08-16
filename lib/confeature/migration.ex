defmodule Confeature.Migration do
  @moduledoc """
  Defines an Ecto migration to create the necesary table to store your feature
  settings.

  Look at the [README](README.md) for detailed setup instructions.

  ## Ecto Prefixes and SQL Schemas

  Confeature has been tested with Ecto multi-tenancy and should work in all
  scenarios, since it just send basic Ecto queries that should be decorated by
  your Ecto repository default configuration.

  If migrations fail, your Repo probably lacks the following callback:

      defmodule MyApp.MyRepo do
        use Ecto.Repo, ...

        def default_options(_operation) do
          [prefix: "your_sql_prefix"]
        end
      end
  """
  use Ecto.Migration

  @doc """
  Creates Confeature table. You can set the following options:

    * `table_name`: lets you specify the table name. Default is `features`.
  """
  def up(opts \\ []) do
    table_name = Keyword.get(opts, :table_name, "features")

    create table(table_name, primary_key: false) do
      add :name, :string, primary_key: true, null: false
      add :attrs, :json, default: "{}"

      timestamps()
    end
  end

  @doc """
  Drops the Confeature table. You can set the following options:

    * `table_name`: lets you specify the table name. Default is `features`.
  """
  def down(opts \\ []) do
    table_name = Keyword.get(opts, :table_name, "features")

    drop table(table_name)
  end
end
