%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: []
      },
      plugins: [],
      requires: [],
      strict: true,
      parse_timeout: 5000,
      color: true,
      checks: %{
        disabled: [
          {Credo.Check.Readability.ModuleDoc, false},
          {Credo.Check.Design.AliasUsage, false}
        ]
      }
    }
  ]
}
