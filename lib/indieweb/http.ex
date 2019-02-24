defmodule IndieWeb.Http do
  @moduledoc """
  Provides a facade for handling HTTP actions.
  """

  def timeout, do: 10_000

  @doc "Obtains an implementation of a `IndieWeb.Http.Adapter` module."
  @spec adapter() :: IndieWeb.HTTP.Adapter.t()
  def adapter,
    do:
      Application.get_env(
        :indieweb,
        :http_adapter,
        IndieWeb.Http.Adapters.HTTPotion
      )

  @doc "Sends a HTTP request to the URI `uri` with the provided options."
  @spec request(binary(), atom(), keyword()) ::
          {:ok, IndieWeb.Http.Response.t()} | {:error, IndieWeb.Http.Error.t()}
  def request(uri, method \\ :get, opts \\ []) do
    adapter().request(uri, method, opts)
  end

  for method <- ~w(get post options head put patch delete)a do
    @doc """
    Sends a #{String.upcase(Atom.to_string(method))} request to the specified URI.

    See `request/3` for more information about making requests.
    """
    def unquote(method)(uri, opts \\ []),
      do: IndieWeb.Http.request(uri, unquote(method), opts)
  end

  def extract_link_header_values(headers) do
    Map.take(headers, ["link", "Link"])
    |> Map.values()
    |> List.flatten()
    |> Enum.map(fn header -> String.split(header, ",", trim: true) end)
    |> List.flatten()
    |> Enum.map(fn header ->
      [rel, value] =
        header
        |> String.trim()
        |> String.split(";")
        |> Enum.reverse()
        |> Enum.map(fn part -> String.trim(part) end)

      rel_values =
        rel
        |> String.split("=")
        |> List.last()
        |> String.trim("\"")
        |> String.split()

      link_value =
        value |> String.trim_leading("<") |> String.trim_trailing(">")

      Enum.map(rel_values, fn rel_value -> {rel_value, link_value} end)
    end)
    |> List.flatten()
    |> Enum.reduce(%{}, fn {key, val}, acc ->
      Map.put(acc, key, Enum.sort(Map.get(acc, key, []) ++ [val]))
    end)
  end

  def make_absolute_uri(path, _) when path in ["", nil], do: path

  def make_absolute_uri(path, base_uri)
      when path == base_uri and is_binary(path),
      do: path

  def make_absolute_uri(path, base_uri) when is_binary(path),
    do: URI.merge(base_uri, path) |> URI.to_string()
end
