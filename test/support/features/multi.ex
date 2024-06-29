defmodule Test.Features.Multi do
  @moduledoc false

  defstruct [:enabled, :margin]

  @type t :: %__MODULE__{
          enabled: boolean(),
          margin: float()
        }
end
