defmodule IndieWeb.App.HxApp do
  @moduledoc """
  Parses h-x-app information from a Website.

  Using the specificiation of h-x-app information outlined at 
  https://indieweb.org/h-x-app. This allows platforms that are
  richly formatted with said markup to be presented to Koype
  in a useful manner.
  """
  @behaviour IndieWeb.App.Parser

  alias Microformats2.Utility, as: MF2

  defp do_format(data) do
    result =
      Enum.reduce_while(
        ~w(x-app app),
        {:error, :no_app_info},
        fn type, acc ->
          case MF2.get_format(data, type) do
            nil ->
              {:cont, acc}

            h_app_data ->
              {:halt, {:ok, h_app_data}}
          end
        end
      )

    case result do
      {:ok, h_app_data} ->
        app_data =
          ~w(name logo url)a
          |> Enum.map(fn key ->
            value = h_app_data |> MF2.get_value(key) |> List.first()
            {Atom.to_string(key), value}
          end)
          |> Map.new()

        {:ok, app_data}

      {:error, _} ->
        result
    end
  end

  @impl true
  def resolve(uri) do
    case MF2.fetch(uri) do
      {:ok, mf2_data} -> do_format(mf2_data)
      false -> {:error, :failed_to_fetch_h_x_app_data}
    end
  end

  @impl true
  def clear(_), do: :ok
end
