defmodule Test.Cache.Dummy do
  @behaviour Confeature.Cache

  def get(_name) do
    nil
  end

  def set(_name, struct) do
    {:ok, struct}
  end
end
