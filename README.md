# PhoenixDuskmoon

[![release](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/actions/workflows/test-and-release.yml/badge.svg)](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/actions/workflows/test-and-release.yml)

Provides Duskmoon UI for Phoenix project.

Require `tailwindcss >= 4.0` and `duskmoonui >= 5.0`

See the [docs](https://hexdocs.pm/phoenix_duskmoon/) for more information.


## Install

Add deps in `mix.exs`
```elixir
    {:phoenix_duskmoon, "~> 6.0"},
```

Include in phoenix view helpers

```elixir
defp html_helpers do
  quote do
    # import all duskmoon ui component
    use PhoenixDuskmoon.Component
    # import all duskmoon ui fun component
    use PhoenixDuskmoon.Fun
  end
end
```

Import `css`

```css
@source "../js/**/*.js";
@source '../../lib/**/*.exs';
@source '../../lib/**/*.ex';

@import "tailwindcss";
@plugin "@tailwindcss/typography";
@plugin "duskmoonui";
@import "phoenix_duskmoon/theme";
@import "phoenix_duskmoon/components";
```

## Live Storybook

[Live Storybook](https://duskmoon-storybook.gsmlg.dev)

![](screenshots/1.png)
![](screenshots/2.png)
![](screenshots/3.png)
![](screenshots/4.png)
