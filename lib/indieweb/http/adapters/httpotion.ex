defmodule IndieWeb.Http.Adapters.HTTPotion do
  @behaviour IndieWeb.Http.Adapter

  @impl true
  def request(uri, method, opts) do
    options = [
      timeout: opts[:timeout],
      follow_redirects: true,
      auto_sni: true,
      headers: Keyword.get(opts, :headers, %{}) |> Map.to_list() |> Keyword.new(),
      direct: nil,
      ibrowse: [],
      body: Keyword.get(opts, :body, nil),
      query: Keyword.get(opts, :query, nil)
    ]

    case HTTPotion.request(method, uri, options) do
      %HTTPotion.ErrorResponse{} = err_resp ->
        {:error, %IndieWeb.Http.Error{message: err_resp.message, raw: err_resp}}

      %HTTPotion.Response{} = resp ->
        {:ok,
         %IndieWeb.Http.Response{code: resp.status_code, body: resp.body, headers: resp.headers, raw: resp}}
    end
  end
end
