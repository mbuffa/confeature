defmodule Test.Features.World do
  @moduledoc false

  defstruct [:margin]

  @type t :: %__MODULE__{
          margin: float()
        }
end
