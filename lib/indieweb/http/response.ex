defmodule IndieWeb.Http.Response do
  @moduledoc "Defines a response obtained when making a network request."
  @enforce_keys ~w(code body headers raw)a
  defstruct ~w(body code headers raw)a

  @type t :: %__MODULE__{
          body: binary(),
          code: non_neg_integer,
          headers: Access.t(),
          raw: any()
        }
end
