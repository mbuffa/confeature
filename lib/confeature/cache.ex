defmodule Confeature.Cache do
  @callback get(name :: any) :: any
  @callback set(name :: any, data :: map) :: {:ok, result :: term} | {:error, reason :: term}
  @callback delete(name :: any) :: any
end
