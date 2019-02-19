defmodule IndieWeb.Http.Adapters.HTTPotion do
  @behaviour IndieWeb.Http.Adapter

  @impl true
  def request(uri, method, opts) do
    options = [
      timeout: Keyword.get(opts, :timeout, IndieWeb.Http.timeout()),
      follow_redirects: true,
      auto_sni: true,
      headers: Keyword.get(opts, :headers, %{}) |> Map.to_list(),
      body: Keyword.get(opts, :body, %{}) |> URI.encode_query,
      query: Keyword.get(opts, :query, nil)
    ] |> Enum.reject(fn {_, v} -> is_nil(v) end) |> Keyword.new

    case HTTPotion.request(method, uri, options) do
      %HTTPotion.ErrorResponse{} = err_resp ->
        {:error, %IndieWeb.Http.Error{message: err_resp.message, raw: err_resp}}

      %HTTPotion.Response{status_code: code, body: body, headers: headers} = resp ->
        {:ok,
         %IndieWeb.Http.Response{code: code, body: body, headers: headers.hdrs, raw: resp}}
    end
  end
end
