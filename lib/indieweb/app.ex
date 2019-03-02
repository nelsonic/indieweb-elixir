defmodule IndieWeb.App do
  @moduledoc "High-level abstraction for application info resolution."

  defmodule Parser do
    @moduledoc """
    Provides serialized information about an application.

    The goal of a parser is to take specialized logic and format it
    such that a user can get the following bits of information about it

    * Name
    * Description
    * Homepage URI
    * Logo

    Other information below are nice to have
    * Categories
    * Author Information
    * Price

    TODO: Allow extending for more types.
    """
    def known() do
      [
        ## Recommended parsers to stop at
        IndieWeb.App.HxApp,

        ## Open stopgap solutions
        IndieWeb.App.Link
        # IndieWeb.App.WebManifest,

        ## Corporate-backed standards
        # IndieWeb.App.OpenGraph,
        # IndieWeb.App.SchemaOrg

        ## Experiments
        # IndieWeb.App.IndieStore
        # IndieWeb.App.IndieWebWiki
      ]
    end

    @doc "Resolves information from the provided URI."
    @callback resolve(uri :: String.t()) :: {:ok, any()} | {:error, any()}

    @doc "Clears out any cached information for the provided URI."
    @callback clear(uri :: String.t()) :: :ok
  end

  @doc "Clears cached information across all parsers."
  @spec clear(uri :: String.t()) :: :ok
  def clear(uri) do
    Enum.each(__MODULE__.Parser.known(), fn parser -> parser.clear(uri) end)
  end

  @doc """
  Obtains information about the application in question.

  TODO: Use <link> information as a fallback.
  TODO: Make this break out at the first match.
  """
  @spec retrieve(uri :: String.t()) :: {:ok, any()} | {:error, any()}
  def retrieve(url) do
    Enum.reduce_while(
      IndieWeb.App.Parser.known(),
      {:error, :no_compatible_parsers},
      &do_handle_parser(url, &1, &2)
    )
  end

  defp do_handle_parser(url, parser, acc) do
    case parser.resolve(url) do
      {:ok, value} ->
        {:halt, {:ok, value}}

      {:error, _} ->
        {:cont, acc}
    end
  end
end
