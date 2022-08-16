defmodule Test.Features.Multi do
  defstruct [:enabled, :margin]

  @type t :: %__MODULE__{
          enabled: boolean(),
          margin: Float.t()
        }
end
