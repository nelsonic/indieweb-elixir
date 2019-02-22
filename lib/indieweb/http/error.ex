defmodule IndieWeb.Http.Error do
  @moduledoc "Defines an error obtained when making a network request."
  @enforce_keys ~w(message)a

  @typedoc "Representative type of errors with `IndieWeb.Http`."
  @type t :: %__MODULE__{message: any(), raw: any()}

  defstruct ~w(message raw)a
end
