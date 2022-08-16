defmodule ConfeatureTest do
  use ExUnit.Case
  doctest Confeature

  setup_all do
    {:ok, ["OK"]} = Redix.pipeline(Test.Redix, [["FLUSHDB"]])
    :ok
  end

  setup do
    # TODO: Factor this in a case template.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Test.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Test.Repo, {:shared, self()})

    :ok
  end

  describe "with dummy cache" do
    test "boolean toggle" do
      Test.Confeature.set!(%Test.Features.Hello{enabled: false})

      refute Test.Confeature.enabled?(Test.Features.Hello)
      Test.Confeature.enable!(Test.Features.Hello)
      assert Test.Confeature.enabled?(Test.Features.Hello)
    end

    test "value setting" do
      Test.Confeature.set!(%Test.Features.World{margin: 0.97})

      assert Test.Confeature.get(Test.Features.World) == %Test.Features.World{margin: 0.97}
    end

    test "multiple values" do
      Test.Confeature.set!(%Test.Features.Multi{enabled: true, margin: 0.25})

      assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }

      Test.Confeature.disable!(Test.Features.Multi)

      assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: false,
               margin: 0.25
             }

      Test.Confeature.enable!(Test.Features.Multi)

      assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }
    end
  end

  describe "with redis-backed cache" do
    test "boolean toggle" do
      Test.Confeature.RedisBacked.set!(%Test.Features.Hello{enabled: false})

      refute Test.Confeature.RedisBacked.enabled?(Test.Features.Hello)
      Test.Cache.Redis.get(Test.Features.Hello)
      Test.Confeature.RedisBacked.enable!(Test.Features.Hello)
      assert Test.Confeature.RedisBacked.enabled?(Test.Features.Hello)
    end

    test "value setting" do
      Test.Confeature.RedisBacked.set!(%Test.Features.World{margin: 0.97})

      assert Test.Confeature.RedisBacked.get(Test.Features.World) == %Test.Features.World{
               margin: 0.97
             }
    end

    test "multiple values" do
      Test.Confeature.RedisBacked.set!(%Test.Features.Multi{enabled: true, margin: 0.25})

      assert Test.Confeature.RedisBacked.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }

      Test.Confeature.RedisBacked.disable!(Test.Features.Multi)

      assert Test.Confeature.RedisBacked.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: false,
               margin: 0.25
             }

      Test.Confeature.RedisBacked.enable!(Test.Features.Multi)

      assert Test.Confeature.RedisBacked.get(Test.Features.Multi) == %Test.Features.Multi{
               enabled: true,
               margin: 0.25
             }
    end

    test "cache deletion" do
      Test.Confeature.RedisBacked.set!(%Test.Features.World{margin: 0.97})

      assert Test.Confeature.RedisBacked.get(Test.Features.World) == %Test.Features.World{
               margin: 0.97
             }

      Test.Confeature.RedisBacked.delete!(Test.Features.World)
      assert Test.Cache.Redis.get(Test.Features.World) |> is_nil()
      assert Test.Confeature.RedisBacked.get(Test.Features.World) |> is_nil()
    end
  end
end
