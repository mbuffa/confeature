defmodule Confeature.Cache do
  @moduledoc """
  A behaviour module for implementing a key-value store cache. Rather than
  implementing its own, `Confeature` lets you pick the implementation and
  leaves the details at your own discretion. Callbacks will be executed to
  avoid sending queries to the database on each call of your `Confeature`
  store.

  Here's an example, that actually doesn't cache anything:

      defmodule MyApp.Cache.Feature do
        @behaviour Confeature.Cache

        @impl true
        def get(_name), do: nil

        @impl true
        def set(_name, struct) do
          {:ok, struct}
        end

        @impl true
        def delete(_name), do: nil
      end

  And here's an example of a cache implemented using ConCache (on top of ETS):

      defmodule MyApp.Cache.Feature do
        @behaviour Confeature.Cache

        def child_spec() do
          Supervisor.child_spec(
            {
              ConCache,
              name: __MODULE__,
              ttl_check_interval: :timer.minutes(1),
              global_ttl: :timer.minutes(60),
              touch_on_read: false
            },
            id: __MODULE__
          )
        end

        @impl true
        def get(name), do: ConCache.get(__MODULE__, name)

        @impl true
        def set(name, data) do
          :ok = ConCache.put(__MODULE__, name, data)
          {:ok, data}
        end

        @impl true
        def delete(name), do: ConCache.delete(__MODULE__, name)
      end

  If necesary, you can of course use a PubSub such as the one provided by
  Phoenix, in case you'd deploy an app with multiple Erlang nodes.

  There's also an example with Redis (via Redix) in the test suite of the
  Confeature Git repository.
  """
  @callback get(name :: any) :: any

  @callback set(name :: any, data :: map) ::
    {:ok, result :: term} | {:error, reason :: term}

  @callback delete(name :: any) :: any
end
