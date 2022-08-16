defmodule Test.Features.Hello do
  defstruct [:enabled]

  @type t :: %__MODULE__{
          enabled: boolean()
        }
end
