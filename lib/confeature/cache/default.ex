defmodule Confeature.Cache.Default do
  @moduledoc """
  Default (and void) caching strategy.
  """

  @behaviour Confeature.Cache

  @impl true
  def get(_name), do: nil

  @impl true
  def set(_name, struct) do
    {:ok, struct}
  end

  @impl true
  def delete(name), do: {:ok, name}
end
