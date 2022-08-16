defmodule Test.Cache.Dummy do
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
