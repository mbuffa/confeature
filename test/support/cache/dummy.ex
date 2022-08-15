defmodule Test.Cache.Dummy do
  def get(name) do
    nil
  end

  def set(name, struct) do
    {:ok, struct}
  end
end
