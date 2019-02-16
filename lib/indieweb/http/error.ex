defmodule IndieWeb.Http.Error do
  @moduledoc "Defines an error obtained when making a network request."
  @enforce_keys ~w(message)a
  @type t :: %__MODULE__{message: any(), raw: any()}
  defstruct ~w(message raw)a
end
