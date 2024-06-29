defmodule Test.Features.Hello do
  @moduledoc false

  defstruct [:enabled]

  @type t :: %__MODULE__{
          enabled: boolean()
        }
end
