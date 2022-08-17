defmodule ConfeatureTest do
  use ExUnit.Case
  doctest Confeature

  setup_all do
    {:ok, ["OK"]} = Redix.pipeline(Test.Redix, [["FLUSHDB"]])
    :ok
  end

  setup do
    # TODO: Factorize this in a case template.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Test.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Test.Repo, {:shared, self()})

    :ok
  end

  describe "SQL functions" do
    test "upsert/1" do
      {:ok, record = %Confeature.Schema{
        attrs: %{enabled: false},
        name: Test.Features.Hello,
      }} = Test.Confeature.SQL.upsert(%Test.Features.Hello{enabled: false})

      {:ok, feature} = Confeature.Type.load(record)

      {:ok, %Confeature.Schema{
        attrs: %{enabled: true},
        name: Test.Features.Hello,
      }} = Test.Confeature.SQL.upsert(%{feature | enabled: true})

      Test.Confeature.delete!(Test.Features.Hello)
    end

    test "get/1" do
      assert Test.Confeature.SQL.get(Test.Features.Hello) |> is_nil()

      {:ok, _} = Test.Confeature.SQL.upsert(%Test.Features.Hello{enabled: false})

      %Test.Features.Hello{enabled: false} = Test.Confeature.get(Test.Features.Hello)
    end
  end

  describe "behavior, without cache" do
    test "toggling a boolean" do
      {:ok, %Test.Features.Hello{enabled: false}} = Test.Confeature.set!(%Test.Features.Hello{enabled: false})

      refute Test.Confeature.enabled?(Test.Features.Hello)
      {:ok, %Test.Features.Hello{enabled: true}} = Test.Confeature.enable!(Test.Features.Hello)
      assert Test.Confeature.enabled?(Test.Features.Hello)
    end

    test "setting a value" do
      {:ok, %Test.Features.World{margin: 0.97}} = Test.Confeature.set!(%Test.Features.World{margin: 0.97})

      assert Test.Confeature.get(Test.Features.World) == %Test.Features.World{margin: 0.97}
    end

    test "setting multiple values" do
      {:ok, %Test.Features.Multi{enabled: true, margin: 0.25}} = Test.Confeature.set!(%Test.Features.Multi{enabled: true, margin: 0.25})

      assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }

      {:ok, %Test.Features.Multi{enabled: false, margin: 0.25}} = Test.Confeature.disable!(Test.Features.Multi)

      assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: false,
               margin: 0.25
             }

      {:ok, %Test.Features.Multi{enabled: true, margin: 0.25}} = Test.Confeature.enable!(Test.Features.Multi)

      assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }
    end
  end

  describe "behavior, with redis-backed cache" do
    test "toggling a boolean" do
      {:ok, %Test.Features.Hello{enabled: false}} = Test.Confeature.RedisBacked.set!(%Test.Features.Hello{enabled: false})

      refute Test.Confeature.RedisBacked.enabled?(Test.Features.Hello)
      {:ok, %Test.Features.Hello{enabled: true}} = Test.Confeature.RedisBacked.enable!(Test.Features.Hello)
      assert Test.Confeature.RedisBacked.enabled?(Test.Features.Hello)
    end

    test "setting a value" do
      {:ok, %Test.Features.World{margin: 0.97}} = Test.Confeature.RedisBacked.set!(%Test.Features.World{margin: 0.97})

      assert Test.Confeature.RedisBacked.get(Test.Features.World) == %Test.Features.World{margin: 0.97}
    end

    test "setting multiple values" do
      {:ok, %Test.Features.Multi{enabled: true, margin: 0.25}} = Test.Confeature.RedisBacked.set!(%Test.Features.Multi{enabled: true, margin: 0.25})

      assert Test.Confeature.RedisBacked.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }

      {:ok, %Test.Features.Multi{enabled: false, margin: 0.25}} = Test.Confeature.RedisBacked.disable!(Test.Features.Multi)

      assert Test.Confeature.RedisBacked.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: false,
               margin: 0.25
             }

      {:ok, %Test.Features.Multi{enabled: true, margin: 0.25}} = Test.Confeature.RedisBacked.enable!(Test.Features.Multi)

      assert Test.Confeature.RedisBacked.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }
    end

    test "deletion" do
      Test.Confeature.RedisBacked.set!(%Test.Features.World{margin: 0.97})

      assert Test.Confeature.RedisBacked.get(Test.Features.World) == %Test.Features.World{
               margin: 0.97
             }

      Test.Confeature.RedisBacked.delete!(Test.Features.World)
      assert Test.Cache.Redis.get(Test.Features.World) |> is_nil()
      assert Test.Confeature.RedisBacked.get(Test.Features.World) |> is_nil()
      assert Test.Confeature.RedisBacked.SQL.get(Test.Features.World) |> is_nil()
    end
  end

  describe "behavior, with another table name" do
    test "simple assertions" do
      # Is our table empty?
      assert Test.Confeature.WithTableName.get(:hello) |> is_nil()

      # Let's create something.
      Test.Confeature.WithTableName.set!(%Test.Features.Hello{enabled: true})

      # Let's make sure it's not in the `features` table.
      assert Test.Confeature.get(Test.Features.Hello) |> is_nil()

      # And check that it's been created in the right table.
      %Test.Features.Hello{enabled: true} =  Test.Confeature.WithTableName.get(Test.Features.Hello)
    end
  end
end
