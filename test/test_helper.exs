~w(cachex)a
|> Enum.each(fn app ->
  {:ok, _pid} = Application.ensure_all_started(app)
end)

ExUnit.start()

ExUnit.configure(
  exclude: [slow: true, skip: true],
  formatters: [ExUnit.CLIFormatter]
)
