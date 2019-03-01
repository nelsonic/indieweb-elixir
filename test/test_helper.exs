ExUnit.start()
Application.ensure_all_started(:cachex)
Application.ensure_all_started(:indieweb)

ExUnit.configure(
  exclude: [slow: true, skip: true],
  formatters: [ExUnit.CLIFormatter]
)
