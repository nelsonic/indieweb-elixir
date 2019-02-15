ExUnit.start()

ExUnit.configure(
  exclude: [slow: true, skip: true],
  formatters: [ExUnit.CLIFormatter]
)
