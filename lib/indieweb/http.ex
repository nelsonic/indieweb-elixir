defmodule IndieWeb.Http do
  defmodule Error do
    @moduledoc "Defines an error obtained when making a network request."
    @enforce_keys ~w(message)a

    @typedoc "Representative type of errors with `IndieWeb.Http`."
    @type t :: %__MODULE__{message: any(), raw: any()}

    defstruct ~w(message raw)a
  end

  defmodule Response do
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

  def make_absolute_uri(path, _) when path in ["", nil], do: path

  def make_absolute_uri(path, base_uri)
      when path == base_uri and is_binary(path),
      do: path

  def make_absolute_uri(path, base_uri) when is_binary(path),
    do: URI.merge(base_uri, path) |> URI.to_string()

  def extract_link_header_values(%Response{} = resp),
    do:
      resp
      |> Map.get(:raw, %{})
      |> Map.get(:opts, [])
      |> Keyword.get(:rels, %{})

  def request(url, method \\ :get, opts \\ []) do
    case IndieWeb.Http.Client.request([url: url, method: method] ++ opts) do
      {:ok, %Tesla.Env{} = env} ->
        {:ok,
         %Response{
           raw: env,
           code: env.status,
           body: env.body,
           headers: env.headers
         }}
    end
  end

  for method <- ~w(get post options head put patch delete)a do
    @doc """
    Sends a #{String.upcase(Atom.to_string(method))} request to the specified URL.

    See `request/3` for more information about making requests.
    """
    def unquote(method)(url, opts \\ []),
      do: IndieWeb.Http.request(url, unquote(method), opts)
  end

  defmodule Client do
    use Tesla

    plug(Tesla.Middleware.DecodeRels)
    plug(Tesla.Middleware.JSON)
    plug(Tesla.Middleware.Compression)
    plug(Tesla.Middleware.KeepRequest)
    plug(Tesla.Middleware.Logger)
    plug(Tesla.Middleware.RequestId)
    plug(Tesla.Middleware.FollowRedirects)

    plug(Tesla.Middleware.Headers, [
      {"user-agent",
       "IndieWeb-Elixir/0.0.42 (https://git.jacky.wtf/indieweb/elixir)"}
    ])
  end
end
