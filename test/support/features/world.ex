defmodule Test.Features.World do
  defstruct [:margin]

  @type t :: %__MODULE__{
    margin: Float.t()
  }
end
