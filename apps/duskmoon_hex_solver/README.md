# DuskmoonHexSolver

Duskmoon fork of HexSolver, a PubGrub based version solver used by
[Hex](https://github.com/hexpm/hex).

The published package is `:duskmoon_hex_solver`. It keeps the upstream
`HexSolver.*` modules so existing callers can migrate by changing only the
Mix dependency.

### References

* [PubGrub: Next-Generation Version Solving](https://nex3.medium.com/pubgrub-2fb6470504f)
* [Solver documentation](https://github.com/dart-lang/pub/blob/master/doc/solver.md)
* [Dart solver implementation](https://github.com/dart-lang/pub)
* [Dart semver implementation](https://github.com/dart-lang/pub-semver)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `duskmoon_hex_solver` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:duskmoon_hex_solver, "~> 9.5"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/duskmoon_hex_solver>.
