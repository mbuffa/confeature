defmodule ConfeatureTest do
  use ExUnit.Case
  doctest Confeature

  setup do
    # TODO: Factor this in a case template.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Test.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Test.Repo, {:shared, self()})

    :ok
  end

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
    assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{enabled: true, margin: 0.25}

    Test.Confeature.disable!(Test.Features.Multi)
    assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{enabled: false, margin: 0.25}

    Test.Confeature.enable!(Test.Features.Multi)
    assert Test.Confeature.get(Test.Features.Multi) == %Test.Features.Multi{enabled: true, margin: 0.25}
  end
end
