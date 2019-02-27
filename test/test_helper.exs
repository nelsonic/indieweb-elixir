ExUnit.start()
Application.ensure_all_started(:cachex)
Cachex.start_link(:indieweb, [])

ExUnit.configure(
  exclude: [slow: true, skip: true],
  formatters: [ExUnit.CLIFormatter]
)
