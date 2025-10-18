## [7.1.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v7.1.2...v7.1.3) (2025-10-18)


### Bug Fixes

* Use full module name for Storybook backend in router ([5975540](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5975540903c9953cca7e9d163b705cd7dd7bafae))

## [7.1.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v7.1.1...v7.1.2) (2025-10-17)


### Bug Fixes

* Use GHCR_TOKEN instead of PERSONAL_ACCESS_TOKEN for GitHub Container Registry ([cceeb80](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/cceeb805a5efda3b220ecb23210f583fc5152489))

## [7.1.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v7.1.0...v7.1.1) (2025-10-17)


### Bug Fixes

* Update Node.js version to 22 and fix Docker registry URLs ([ce440fb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ce440fb111988984bad9fa313a5e03e36fcef542))

# [7.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v7.0.1...v7.1.0) (2025-10-17)


### Bug Fixes

* Add Node.js 22 setup for semantic-release compatibility ([8850db4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8850db4a151fff81e11411f2d94bd25e31b7912f))
* Remove npm cache configuration to avoid lock file errors ([4eeb684](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4eeb684c7459a6b52dd8ae169e69a726b56a1395))
* Specify correct npm cache path for Node.js setup ([f7aa4fe](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f7aa4fe4b48a75aa69a1c2686e6459e18496c591))


### Features

* Enhance UI components with accessibility improvements and new features ([#13](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/13)) ([ca5a0dd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ca5a0ddcebaa241a70e810cc15401137ed20672d))

# [8.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v8.0.0...v8.1.0) (2025-10-14)


### Features

* Refactor left_menu components with daisyUI integration and comprehensive test coverage ([3efb4ad](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3efb4adf531e29fefead182d51ab67580ae8806e))

# [8.0.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v7.0.1...v8.0.0) (2025-10-13)


### Features

* Add 12 new advanced form input types with comprehensive storybook coverage ([856cebf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/856cebfecbaa67dfdb5a2330acd8aaa04421d95b))
* Add comprehensive Skeleton component and fix storybook configuration ([6e5b730](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6e5b730240cfea521df7589bf79edb3b46d2c5aa))
* Enhance components with comprehensive duskmoonui integration ([60fb90f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/60fb90fc92c5bb3e709b3a3bbcb419127787ff3e))
* Optimize /hook, /mdi, and /bsi pages with performance and UX improvements ([dc7e1b0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/dc7e1b0dc8c3761947b92f2ee7ccdd1211ebd10d))


### BREAKING CHANGES

* Storybook moved from lib/storybook to storybook/ directory

## [7.0.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v7.0.0...v7.0.1) (2025-10-08)


### Bug Fixes

* Disable PhoenixStorybook to resolve CI/CD compilation failure ([3f549ce](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3f549ce4f087310a823ab4a9f3eb0a9bde6b2f5d))
* Update Phoenix dependencies and complete Storybook index configuration ([c442095](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c44209542d2171869ea31578930392933b40268a))

# [7.0.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.3.2...v7.0.0) (2025-10-02)


### Bug Fixes

* Fix storybook. ([640b03d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/640b03d57826bb8bc46d432e07173f92040ec7d4))
* Fix. ([5aa04e3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5aa04e309c2b068ca9006a5629d83017294788ab))
* Fix. ([60be998](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/60be998f1ea056032cc020281d2dcba80d6e0676))
* Resolve PhoenixStorybook compilation warning by adding content entries to index files ([577a887](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/577a8872c9626bfff3b9bf3406a7eca8275389fc))
* Update dependencies to resolve compilation warnings ([6f9d050](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6f9d0507c22093bab534f2d8b25eb9dc50e4ca41))


### Code Refactoring

* Replace daisyui with duskmoonui dependency ([3aace17](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3aace172cec493c877318825bfc180bdda6415a1))


### Features

* Add comprehensive component tests for Button, Card, Icons, and Link ([3df36f7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3df36f7a33532ce935b6cc4b7395227b4088fc5e))
* Add devenv development environment configuration ([6c010b9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6c010b9aa07ae66e472e112778849f3b2eb94b18))


### BREAKING CHANGES

* Update css library to duskmoonui instead of daisyui.

## [6.3.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.3.1...v6.3.2) (2025-05-29)


### Bug Fixes

* Remove tailwind.config.js, use directive instead. ([5726376](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/57263769b83c6698595ac6ce68f6968539d795c6))

## [6.3.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.3.0...v6.3.1) (2025-05-29)


### Bug Fixes

* Fix. ([0b9f4aa](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/0b9f4aaaeb3b3163194140c1f67db53adae7b486))
* Fix. ([6d109ef](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6d109ef3cf06c3c282fbe03b5414b4a04aaba5a4))
* Fix. ([88ba112](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/88ba1124c1930c0b0cc3191f6b737b26b4010619))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-08)


### Bug Fixes

* Fix neumorphic form. ([a02cfb2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a02cfb2ecad7342779fcd13895693bcb74d45c0c))
* Fix neumorphic table. ([139b524](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/139b524f7147a346e3ef1e69943d873946dc5c19))
* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix tasks. ([719b3ea](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/719b3ead86f1bcaba7aabba147082d1b928fdc3e))
* Fix. ([f2a7f0e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f2a7f0ebdbe27eb32381dc54a45260d7cc432d46))
* Fix. ([481f6d5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/481f6d517438f5bb280c1368dbf2abde8060ee79))
* Fix. ([765d62a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/765d62a98e4580cd303a5cec4785c902fb67c41f))
* Fix. ([01f271d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/01f271dd9335cae55b6eb76046ac7089ccaa1616))
* Fix. ([8549218](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8549218454639fa42f21a1897ec848c9332fc5fd))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-08)


### Bug Fixes

* Fix neumorphic form. ([a02cfb2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a02cfb2ecad7342779fcd13895693bcb74d45c0c))
* Fix neumorphic table. ([139b524](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/139b524f7147a346e3ef1e69943d873946dc5c19))
* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix tasks. ([719b3ea](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/719b3ead86f1bcaba7aabba147082d1b928fdc3e))
* Fix. ([f2a7f0e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f2a7f0ebdbe27eb32381dc54a45260d7cc432d46))
* Fix. ([481f6d5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/481f6d517438f5bb280c1368dbf2abde8060ee79))
* Fix. ([765d62a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/765d62a98e4580cd303a5cec4785c902fb67c41f))
* Fix. ([01f271d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/01f271dd9335cae55b6eb76046ac7089ccaa1616))
* Fix. ([8549218](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8549218454639fa42f21a1897ec848c9332fc5fd))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-08)


### Bug Fixes

* Fix neumorphic form. ([a02cfb2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a02cfb2ecad7342779fcd13895693bcb74d45c0c))
* Fix neumorphic table. ([139b524](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/139b524f7147a346e3ef1e69943d873946dc5c19))
* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix tasks. ([719b3ea](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/719b3ead86f1bcaba7aabba147082d1b928fdc3e))
* Fix. ([765d62a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/765d62a98e4580cd303a5cec4785c902fb67c41f))
* Fix. ([01f271d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/01f271dd9335cae55b6eb76046ac7089ccaa1616))
* Fix. ([8549218](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8549218454639fa42f21a1897ec848c9332fc5fd))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-07)


### Bug Fixes

* Fix neumorphic form. ([a02cfb2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a02cfb2ecad7342779fcd13895693bcb74d45c0c))
* Fix neumorphic table. ([139b524](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/139b524f7147a346e3ef1e69943d873946dc5c19))
* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix tasks. ([719b3ea](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/719b3ead86f1bcaba7aabba147082d1b928fdc3e))
* Fix. ([8549218](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8549218454639fa42f21a1897ec848c9332fc5fd))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-07)


### Bug Fixes

* Fix neumorphic form. ([a02cfb2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a02cfb2ecad7342779fcd13895693bcb74d45c0c))
* Fix neumorphic table. ([139b524](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/139b524f7147a346e3ef1e69943d873946dc5c19))
* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix tasks. ([719b3ea](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/719b3ead86f1bcaba7aabba147082d1b928fdc3e))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-07)


### Bug Fixes

* Fix neumorphic form. ([a02cfb2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a02cfb2ecad7342779fcd13895693bcb74d45c0c))
* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix tasks. ([719b3ea](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/719b3ead86f1bcaba7aabba147082d1b928fdc3e))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-07)


### Bug Fixes

* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix tasks. ([719b3ea](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/719b3ead86f1bcaba7aabba147082d1b928fdc3e))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-06)


### Bug Fixes

* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))
* Fix. ([9db4a9f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db4a9fb074c8f900d861ff4b5b7fb86f904881b))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

# [6.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.3.0) (2025-03-06)


### Bug Fixes

* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))


### Features

* Add neumorphic design. ([8b1c697](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8b1c697d1689560873a357a1b5bd512dcd153ac0))

## [6.2.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.2.1) (2025-02-22)


### Bug Fixes

* Fix pagination. ([3920dcb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3920dcbdd50e38ae6026d045c107235988cfff6f))
* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))

## [6.2.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.2.0...v6.2.1) (2025-02-22)


### Bug Fixes

* Fix simple_app_bar. ([63108a1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/63108a1d86223be7f44e680d37ebfb4e5b2bca84))

# [6.2.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.1.3...v6.2.0) (2025-02-12)


### Features

* Add dm_navbar. ([a2f525d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a2f525dafafc9f9b0b0262ea2ade213c7307d0a7))

## [6.1.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.1.2...v6.1.3) (2025-02-10)


### Bug Fixes

* Fix theme. ([259fbb4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/259fbb4c7b24ce870f97053fd2234cd3f86df495))

## [6.1.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.1.1...v6.1.2) (2025-02-10)


### Bug Fixes

* Fix style. ([8831316](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/88313169f8f31729aadd3ad61918a8528e36ed16))
* Fix style. ([5e7f8c1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5e7f8c132fb2d14e4cc4ba375a07329432c5bddb))

## [6.1.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.1.0...v6.1.1) (2025-02-10)


### Bug Fixes

* Fix snowflake overflow. ([44c28ae](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/44c28ae9830085b2536a823b441d1e38b2318fff))

# [6.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.10...v6.1.0) (2025-02-09)


### Features

* Move effect loading to fun component. ([521402a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/521402af8e250a04ea1e0a9508c20447be9bc189))

## [6.0.10](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.9...v6.0.10) (2025-02-09)


### Bug Fixes

* Add prefix to fun component, avoid conflict. ([5b52cc0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5b52cc0c96c9a979b19053f61b9a6a8ea757d714))

## [6.0.9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.8...v6.0.9) (2025-02-09)


### Bug Fixes

* Fix package.json files. ([885e8e9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/885e8e9515e310352f6c65525c2059aea0822977))
* Fix package.json. ([9db1241](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9db1241af76fa8e7a7dd195cb9d8ccb163cc7e19))

## [6.0.8](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.7...v6.0.8) (2025-02-06)


### Bug Fixes

* Fix missing css. ([a709509](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a70950966ebea82ac858ab7e6e6ec8196fe17e88))

## [6.0.7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.6...v6.0.7) (2025-02-06)


### Bug Fixes

* Fix theme. ([f9175ec](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f9175ec02a49d9e7f98fea0645f8db066892fb7c))

## [6.0.6](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.5...v6.0.6) (2025-02-06)


### Bug Fixes

* Fix Dockerfile. ([c6d93f0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c6d93f057265cfe8457effab27a030b76e38049d))
* Fix. ([9fa74d6](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9fa74d685340d1ae05b29697354897c1e351057a))

## [6.0.5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.4...v6.0.5) (2025-02-05)


### Bug Fixes

* Fix Dockerfile. ([ff5421d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ff5421de20fe37525343167628ca5c0bb30130d4))

## [6.0.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.3...v6.0.4) (2025-02-05)


### Bug Fixes

* Fix Dockerfile. ([438cd87](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/438cd87ea62423d6a6bb3cfbf49b50b8133dc7e0))

## [6.0.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.2...v6.0.3) (2025-02-05)


### Bug Fixes

* Fix Dockerfile. ([fc778e1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fc778e18ace260ed9b2bf28057b2f80cc3f5c032))

## [6.0.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.1...v6.0.2) (2025-02-05)


### Bug Fixes

* Fix Dockerfile and remove useless. ([f833766](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f833766350b2ee557c77a573b9db54630b95b655))

## [6.0.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v6.0.0...v6.0.1) (2025-02-05)


### Bug Fixes

* Fix docs and ci. ([b98f34d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b98f34dacfd6f79c58ef1a837678190cddf64225))

# [6.0.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.1.0...v6.0.0) (2025-02-05)


### Bug Fixes

* Fix button [@id](https://github.com/id). ([e544f0c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e544f0cd5dfc1f340f2bf0877c0532b7391a55d3))


### Features

* Update Tailwind CSS to 4.0 ([#11](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/11)) ([b2974a4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b2974a4915fd17df8784ef37dbeade1713ca89d3))


### BREAKING CHANGES

* * Update tailwindcss to 4.0 and duskmoonui to 5.0.
* Remove legacy `use PhoenixDuskmoon`

# [5.2.0-beta.5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.2.0-beta.4...v5.2.0-beta.5) (2025-02-05)


### Bug Fixes

* Remove useless css. ([91d1682](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/91d16827299a23f13cc433e7aba742c3e02c1335))


### Features

* Add theme. ([2f46764](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2f46764a13f2dd49bbe9681a482658ac9a97448a))

# [5.2.0-beta.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.2.0-beta.3...v5.2.0-beta.4) (2025-02-05)


### Bug Fixes

* Fix docs. ([39d9fb3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/39d9fb3d24f94b536c517ccf4c1429c7b4cb1c69))
* Fix README.md. ([81ebcbf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/81ebcbf5ef62e214def285516be132dc64001393))

# [5.2.0-beta.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.2.0-beta.2...v5.2.0-beta.3) (2025-02-04)


### Bug Fixes

* Fix storybook name. ([20ef181](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/20ef181df1b9892f5e5886220e23ebed4de0388b))
* Fix. ([a9bb7b4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a9bb7b45482ee54c158bf06e046b76c68a77a807))
* Fix. ([e16f8fd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e16f8fd8971be38143873bf901c167b6ac02d6b3))

# [5.2.0-beta.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.2.0-beta.1...v5.2.0-beta.2) (2025-02-04)


### Bug Fixes

* Fix. ([a36d8b4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a36d8b44d205126774773b4135b65cb07baea9b5))

# [5.2.0-beta.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.1.0...v5.2.0-beta.1) (2025-02-04)


### Bug Fixes

* Add fun spotlight. ([8fdd70e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8fdd70e259af9fa39bfd13f18b08a1a75cd8cb15))
* Add fun spotlight. ([693f6dd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/693f6dd1bbfd01c89cb18438d010efe98d75c027))
* Fix atom and snow. ([5a6c85f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5a6c85fcbdebf4d47b87b212fc017564026e5b1a))
* Fix atom overflow. ([fc7753a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fc7753a1ed5df69bbfb3773cb0ff6d8fa1964ecd))
* Fix build. ([f80a79e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f80a79e5808625291570f73db3d5f55ef91e71fa))
* Fix build. ([51547e2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/51547e2b68146381fb909da21b34ec203660cfea))
* Fix button [@id](https://github.com/id). ([1ca0bbc](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1ca0bbc21da7ce213997fc6daa66e483678ff0ed))
* Fix button [@id](https://github.com/id). ([e544f0c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e544f0cd5dfc1f340f2bf0877c0532b7391a55d3))
* Fix ci version. ([7f2005e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7f2005e3c92061ddfe50e6081699ed4706f26a5e))
* Fix ci. ([75c4bcd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/75c4bcdb79697279f8e155d750051fdaa003ceee))
* Fix ci. ([6085fcd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6085fcd1220bbba25322d4804fd59a065d8d4f3b))
* Fix ci. ([bf15d5d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/bf15d5d66c72e62f3bb904adc72b4573704f4c2e))
* Fix gettext. ([c9a1419](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c9a1419c53224128abeddd987092595005995301))
* Fix order. ([79d0b20](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/79d0b208b0535f271056692c5a5e2750ccbf59b0))
* Fix pagination. ([492b810](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/492b810047db09e420b2e7fa80927e32b163b7b2))
* Fix spotlight. ([71abaa3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/71abaa3a7f75404462bb41007d299226ee94e2d0))
* Fix. ([c7839d7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c7839d79533e2aa77a9265c09003637174c3d385))
* Fix. ([ad83066](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ad83066583e9513ab2550a8f5e9dc651b936a018))
* Fix. ([cc3f899](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/cc3f899791ca20b7be501d3b1038094f950d85e7))
* Fix. ([0617096](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/061709601de8ad750138ee755665135fd0c5ea34))
* Fix. ([7940600](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/79406000c0b3ab4ce2a7b6b56eb2aaca3417fca6))
* Fix. ([ab9fbd3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ab9fbd34162f8439f9030e576a3f7ec5659e4f86))
* Fix. ([2f4cfe4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2f4cfe4cdc7942326eb752fda9b9dce6845882c6))
* Fix. ([fc7cb0b](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fc7cb0b49b7faff5e475cce15b52da0ec3ac5ef1))
* Fix. ([6e8366c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6e8366c21b3b6562137b17827a20d13f82307b11))
* Fix. ([7f0a6f0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7f0a6f0812d3f3255539aa28379f8f79daf34315))
* Fix. ([7edb06e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7edb06ee7c386cd1e47dd5bfb9bf7a2fec1bd152))
* Update bsi bootstrap icons. ([cb9354a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/cb9354ad20c4d04303291f07af7319b4d959c059))
* Update mdi material design icons. ([598222a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/598222a45081989bb9106d6f63ef544819b21203))
* Update new tailwind css. ([b9253df](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b9253df07ccafdc87e05eb10dc91da21ba123866))
* Update tailwind and duskmoonui. ([5129da5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5129da5963bda3fa0047940946a73b62f42a4760))
* Use npm workspace. ([e5fa0a2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e5fa0a2254cee3f6071ee5da86692d5968479474))


### Features

* add confirm slot to btn. ([c839278](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c839278b8c61a5bd277dd340717efae65196931e))
* Add dm_compact_input. ([821849a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/821849a5e5b2cd49e84d7526258e792609173d66))
* Add fun element. ([db3a22b](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/db3a22bcd881af1e8176b4ed5cc89a5a994befa0))

## [5.1.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.1.0...v5.1.1) (2025-01-25)


### Bug Fixes

* Fix button [@id](https://github.com/id). ([e544f0c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e544f0cd5dfc1f340f2bf0877c0532b7391a55d3))

# [5.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.0.6...v5.1.0) (2025-01-21)


### Bug Fixes

* Fix. ([5272c03](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5272c035271ba83059a0be3ffc701660d15ef58f))


### Features

* add confirm slot to btn. ([50d22f8](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/50d22f87aee724e0041a48289cbc21474fde6104))

## [5.0.6](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.0.5...v5.0.6) (2025-01-21)


### Bug Fixes

* Fix ci. ([a5590bb](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a5590bb26df39b27b68837e64f83e9ddb4aab1cc))
* Fix ci. ([ba095d1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ba095d1ca79fb9762e635fe88d6389e4547dd1c5))

## [5.0.5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.0.4...v5.0.5) (2025-01-21)


### Bug Fixes

* Fix build. ([4001505](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/400150561534cd2f7fd3d054e312d0be7038bc25))
* Fix ci version. ([168a499](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/168a4990576b011f4883cc1f7c12d4d568ba9d0a))
* Fix ci. ([6b39123](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6b3912363b90c9faa77965afe7b842e7c64900b4))

## [5.0.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.0.3...v5.0.4) (2025-01-21)


### Bug Fixes

* Fix build. ([dc45b47](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/dc45b47aa685c5ae5f12b009c10b4488d530f58d))

## [5.0.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.0.2...v5.0.3) (2025-01-20)


### Bug Fixes

* Fix. ([27c37e7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/27c37e7bc213438744ab37f85f90f1442ce9db0b))
* Fix. ([ac5810b](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ac5810b2aa7ffdb7fac68523054f60766d581b8e))
* Fix. ([9a2c8b3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9a2c8b340fc76529994894f12eb2c466acaa0440))
* Use npm workspace. ([e03932e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e03932ed0ebe52e63473c2ceec687b284a2ff7f5))

## [5.0.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.0.1...v5.0.2) (2025-01-17)


### Bug Fixes

* Update deps. ([317c99c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/317c99cfc6bcf3c853f2039fb8cb86b0dda1c2a4))

## [5.0.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v5.0.0...v5.0.1) (2025-01-14)


### Bug Fixes

* Fix form and dm_input type. ([0896d5b](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/0896d5bc466a2078a299ce8c22c677cd7b0ca0e2))

# [5.0.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.6.6...v5.0.0) (2024-12-13)


### Bug Fixes

* Format code. ([c45a594](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c45a59431d50206d7a0742231dca55cb63144ea3))


### Features

* Add button with confirm. ([3a5491c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3a5491cfc59c8ac0083682a0d3f31d9ba9750d5c))
* Update phoenix_live_view to 1.0 ([7f04b3a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7f04b3a74c9ce4665ae97f2349ab0d691ce1f950))


### BREAKING CHANGES

* * phoenix_live_view version up to 1.0, can not compatible to previous version

## [4.6.6](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.6.5...v4.6.6) (2024-08-09)


### Bug Fixes

* Add input toggle and storybook. ([ad531ee](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ad531eec357abbc04be954a12989df54fdd9ac22))
* Fix format. ([5da5d3e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5da5d3ed2ecc930b75f68dc05764858e5e64c7e3))
* Fix format. ([b8fbb53](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b8fbb53f31ac6c0c88effc1b9ef05103f0da3cda))
* Fix leftmenu. ([0a9591f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/0a9591f8c417b02620720fb7442187a63ca48c1c))
* Fix link and storybook. ([79b76fd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/79b76fdd7cd7e1b7d417b472d070df495c5cd26e))
* Fix table. ([6ea2b1c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6ea2b1c5b75a51bf62b07959a30927ca25970bce))
* Ignore warning as error. ([4e839c0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4e839c0017c1af1f990ad5a9473b51c61b4dbe07))

## [4.6.5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.6.4...v4.6.5) (2024-08-01)


### Bug Fixes

* Add dm_pagination_thin with loading and jumper. ([d1c013a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/d1c013ad2908746c514bb82e6bdaf3a2bbc1500d))
* Add flash. ([2c1594c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2c1594c5b307c0ce09fbc6654efcb905d536a6d8))
* Fix style. ([2e44767](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2e44767209047eea69324f47dacc81341a4f6bed))
* Fix style. ([a9f8b9c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a9f8b9c5f1c2404ec9212eea5d686a647e8929ca))
* Fix. ([a1bb3d0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a1bb3d03739819b25b9c2f94cb32f596ed07f714))

## [4.6.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.6.3...v4.6.4) (2024-07-10)


### Bug Fixes

* Fix table border. ([55d0596](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/55d0596e20372fedc7bf0d82f87694b9dc74d030))

## [4.6.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.6.2...v4.6.3) (2024-07-09)


### Bug Fixes

* Fix table. ([37c5220](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/37c5220ace8437e81c2a062eafba7fcd073c0fc0))

## [4.6.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.6.1...v4.6.2) (2024-07-09)


### Bug Fixes

* Fix async card. ([14c7ad6](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/14c7ad629e66102efabac2ef8d74407f83d0f43c))

## [4.6.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.6.0...v4.6.1) (2024-07-09)


### Bug Fixes

* Fix card and async card. ([87c9b5a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/87c9b5a1b3aadc44a196ac66308e20c06aaa17ab))

# [4.6.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.5.2...v4.6.0) (2024-07-08)


### Bug Fixes

* Fix styles. ([aac7a9d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/aac7a9d569e6a59fb066d95d1a0c6707959ce774))
* Optimize with duskmoonui. ([0dcc9be](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/0dcc9beebf3419877b60510d6072accd0fd7c389))


### Features

* Rename PhoenixDuskmoon => PhoenixDuskmoon.Component. ([5325239](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/53252395d99b4b586a0eeb15c77f497c124182b6))

## [4.5.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.5.1...v4.5.2) (2024-07-08)


### Bug Fixes

* Add expand to table. ([1dd3282](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1dd3282fc47bdda7b955881bad45f65607c2aa75))
* Fix style. ([f7a5624](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f7a56244514e4814ec0daa0ed0650ea255d8bfb1))

## [4.5.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.5.0...v4.5.1) (2024-07-04)


### Bug Fixes

* Fix tailwindcss. ([f675f86](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f675f86df77a8b08e634e5238767d2e0cd0dad27))

# [4.5.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.4.4...v4.5.0) (2024-07-04)


### Features

* Add new form module, async card. ([81cfba2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/81cfba2866351d3e249d567bdefb683a636ee66b))

## [4.4.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.4.3...v4.4.4) (2024-05-15)


### Bug Fixes

* Add stream support to table. ([6692ef5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6692ef5481d414d0d95aeb91b91e25f3548c0637))
* Add stream support to table. ([bdebd74](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/bdebd74b351befc5e79d695cb011aa6634024381))

## [4.4.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.4.2...v4.4.3) (2024-05-15)


### Bug Fixes

* Update version. ([099146d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/099146d6b79b98ba18f6f24ee052b894e3bd1df3))

## [4.4.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.4.1...v4.4.2) (2023-05-02)


### Bug Fixes

* Fix z-index. ([d9face9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/d9face9005799095b63119d291efd8bdb66e738c))

## [4.4.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.4.0...v4.4.1) (2023-04-22)


### Bug Fixes

* Fix page header and page footer responsive design. ([5bb5ed6](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5bb5ed6de68db74b586007359d91fd14a736ed0d))

# [4.4.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.3.2...v4.4.0) (2023-04-20)


### Features

* Add responsive feature to table, fix let to :let, fix tab styles. ([037ca1b](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/037ca1bd87204b1b85a6fd98a6c7cf73cd2be679))
* Rename table rows to data, change actionbar struct. ([9cb0c85](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9cb0c858a6c322a4c82d1cd5c58ee7b2691e3fe1))

## [4.3.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.3.1...v4.3.2) (2023-04-17)


### Bug Fixes

* Fix docker. ([1cdcdce](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1cdcdced71cf192347ae9fef9cd056e43629a1d0))

## [4.3.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.3.0...v4.3.1) (2023-04-17)


### Bug Fixes

* Remove @gsmlg/lit from package. ([686f0c3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/686f0c3dcf0c29d8eb446f00b28aed316aa7034a))

# [4.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.2.0...v4.3.0) (2023-04-17)


### Bug Fixes

* Fix duplicate import. ([4dd5134](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4dd5134f40b73686819c3729427a5b39bf2cf954))
* Fix modal style and docs. ([18a4a63](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/18a4a63bde1951b1b052c7024bb0d0cba04ab19a))
* Fix tab styles. ([3fd932d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3fd932d9bbf9250be2b0fcade67d3c9df44e84dc))


### Features

* Add tab and change modal use html dialog. ([8a85659](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8a856591c3610863e2525a222dee96dedebfa935))

# [4.2.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.1.1...v4.2.0) (2023-04-07)


### Features

* Update dependencies. ([c96562f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c96562fa07d90c07eb8d93e132caf2212c83705e))

## [4.1.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.1.0...v4.1.1) (2023-04-02)


### Bug Fixes

* fix style of storybook. ([8374539](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/837453928c5b4f78480e9907c0d9e9194af74751))

# [4.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v4.0.0...v4.1.0) (2023-04-02)


### Features

* Add new loading effect. ([822ba08](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/822ba0824c39d0a75acefd1f0ad68c3e14d2aa49))

# [4.0.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.2.4...v4.0.0) (2023-03-11)


### Bug Fixes

* Fix name prefix. ([1abd013](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1abd013581d509e053d34d2a448348b5705b674e))
* Fix rename issue and dark mode issue. ([ffc6022](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ffc6022b9110d10fc003d141dbb9c5125529e499))
* Fix rename issue. ([0a28820](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/0a28820e959730a447624b2d88a498c8b4b3272b))
* Fix rename issure. ([8d72f0c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8d72f0c56e8713be82adc5458c86ffb613a32d35))


### Features

* Rename to phoenix_duskmoon ([#10](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/10)) ([e61fd9d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e61fd9d7179c0bdc990c87b4ced20a3cd17953a1))


### BREAKING CHANGES

* RENAME PHOENIX_WEBCOMPONENT TO PHOENIX_DUSKMOON.

* fix: Also rename storybook.

* docs: Fix docs.

* fix: Fix url.

## [3.2.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.2.2...v3.2.3) (2023-03-10)


### Bug Fixes

* Add footer to page layout. ([0bb698b](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/0bb698bd11d3c9ddaf7611d10be69a966c9e310e))

## [3.2.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.2.1...v3.2.2) (2023-03-10)


### Bug Fixes

* Fix style. ([fd295f9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fd295f9e9ac0ee65fe1e86af70444f542b171448))

## [3.2.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.2.0...v3.2.1) (2023-03-10)


### Bug Fixes

* Fix build. ([c9099cc](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c9099cc0c77df0d8126eeaedfe33c54bff38aeff))

# [3.2.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.1.5...v3.2.0) (2023-03-10)


### Features

* Add new Home page to document page. ([#9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/9)) ([9f813c7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9f813c73c6a2fef26a130fc1fe6cf346d8e112da))

## [3.1.5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.1.4...v3.1.5) (2023-03-09)


### Bug Fixes

* Fix build. ([a14faa4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a14faa49b589ba194718235d476af222a64da8e7))

## [3.1.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.1.3...v3.1.4) (2023-03-05)


### Bug Fixes

* Change appbar, make it more customizable. ([2d1da27](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2d1da276fac5cb47b4fe28b6cfb7852e926791e5))

## [3.1.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.1.2...v3.1.3) (2023-03-05)


### Bug Fixes

* Fix ci and docs. ([b10a828](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b10a828b8023f00e6420371eb0976129fda56570))

## [3.1.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.1.1...v3.1.2) (2023-03-04)


### Bug Fixes

* Fix build system. ([f9f8ba1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f9f8ba1db6849ea73b6655d85b413b3bf9cc3cb5))
* Fix format. ([de8699e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/de8699ee694b62e42fcaf8172cd651bbeea60328))

## [3.1.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.1.0...v3.1.1) (2023-03-04)


### Bug Fixes

* Remove base css. ([fc85ed8](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fc85ed83245d8f85022bca061ee7db29f14a0bd7))

# [3.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v3.0.0...v3.1.0) (2023-03-04)


### Bug Fixes

* Add color attribute to dm_mdi. ([00ad870](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/00ad87073ae5fbb159d55438a08adffcd9fdfb18))
* Add exports in package.json. ([c2b4df1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c2b4df1db019c4d7f0c1d12eb6c5e527d038c570))
* Add new link storybbok. ([2234b3d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2234b3dbe84e0c99b48507a6c92c6acd3a1ae2ab))
* Fix @gsmlg/lit. ([ababf12](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ababf129ca57883ed51f3cc87b19885dbf7718ad))
* Fix build yew icons. ([76f2972](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/76f2972c267ca03cc831fc18c4a07a942777f875))
* Fix build yew icons. ([29d5ff5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/29d5ff582947cc666228538f6e3951a9800f5d33))
* Fix code format. ([3bc9871](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3bc98717effd367718ddefb23f52b56c0baadf19))
* Fix default value. ([f14a0c7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f14a0c75055be67fd24733f82f9606f1ee7364ac))
* Fix exports at package.json and docs of table. ([836d2b1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/836d2b12803c5e2d3e3152e744f761e5aaa38fd7))
* Fix format. ([4ac5cc4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4ac5cc4d1db2b3fa1698508e12dc090fc843757a))
* Fix format. ([476dd84](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/476dd84ae6b1301e361457a2867ff9a2068d0271))
* Fix import. ([a42689e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a42689e7e46e355a506680efcf9ba3d8cca35ba3))
* Fix left_menu storybook. ([87fd7ac](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/87fd7aca9e0c098f6dbe9d80e7225741f23d7b2f))
* Fix linke style. ([38d2dbf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/38d2dbfde433f647dbd741ab215f438767401b35))
* Fix lint issue. ([2516b4f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2516b4f4990eaba49810097062acb23e1baa8ebe))
* Fix livebook update issue. ([376233f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/376233f89737f39982c54b966b0726d6c9e55557))
* Fix storybook update. ([a613cc1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a613cc1e1b07271996c68ca0e0ec1ad66605da64))
* Fix storybook, rename phx_live_storybook to Phoniex.Storybook. ([82de3d1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/82de3d1d3ab58217ecc76273f1749233b43038c9))
* Fix test. ([4d1a56e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4d1a56e2a6d6f054580f69c089f31c00cef5c705))
* Fix test. ([8490170](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8490170d7becea97061c8842e6274c1dc9174cc0))
* Format class to array. ([b3b29bf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b3b29bf5e4f5ff985bedf10975c153d20d4bd7b0))
* Optimize menu. ([9864d5e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9864d5ed7262678c3de22aa19e82b9e16180e6c9))
* Remove elixir 1.11. ([3e59cbc](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3e59cbc8e0c24e7713228ccf20899e6bd7371512))
* Update @gsmlg/lit version. ([311f257](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/311f257f6bfc54f399d06c0b4bd0eabae12c8a11))
* Update @gsmlg/lit. ([5fb7a17](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5fb7a170f4faad16d58b17df1d176a2d07466a6d))
* Use local icon instead. ([a623091](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a623091b9f405d401e367935a3e657b72452f228))
* Use macro. ([87f2554](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/87f25548b2df510536bea5edd2828881719d5375))


### Features

* Add bootstrap icons. ([21d76e1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/21d76e18b91d075ded072067a12d123b2050a8da))
* Add Breadcrumb component. ([72b1812](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/72b1812d4568c98abe48cdea05445e7184823f14))
* Add material design icons community version. ([2ee18ad](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2ee18adbeee0c2cb164f6177752af6e586b2349f))
* Add new appbar dm_simple_appbar. ([4101601](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4101601b24f09e9f4133f8c07f423a632025a641))
* Add dm_modal. ([2b2a951](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2b2a95107e9c55066084694bab7695cbc98ad8dc))
* Refactor left_menu. ([575fa11](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/575fa111d6ad4f513ad8ce5730d75eb20293353e))
* Support live story book 0.4.0. ([0c5ff02](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/0c5ff0269bbe16822c7c633eac5bee42e07e5bf1))

# [2.7.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.6.0...v2.7.0) (2023-02-17)


### Bug Fixes

* Fix build yew icons. ([76f2972](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/76f2972c267ca03cc831fc18c4a07a942777f875))
* Fix build yew icons. ([29d5ff5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/29d5ff582947cc666228538f6e3951a9800f5d33))
* Fix format. ([4ac5cc4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4ac5cc4d1db2b3fa1698508e12dc090fc843757a))
* Fix import. ([a42689e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a42689e7e46e355a506680efcf9ba3d8cca35ba3))
* Fix left_menu storybook. ([87fd7ac](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/87fd7aca9e0c098f6dbe9d80e7225741f23d7b2f))
* Format class to array. ([b3b29bf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b3b29bf5e4f5ff985bedf10975c153d20d4bd7b0))
* Optimize menu. ([9864d5e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9864d5ed7262678c3de22aa19e82b9e16180e6c9))
* Use macro. ([87f2554](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/87f25548b2df510536bea5edd2828881719d5375))


### Features

* Add dm_modal. ([2b2a951](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2b2a95107e9c55066084694bab7695cbc98ad8dc))
* Refactor left_menu. ([575fa11](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/575fa111d6ad4f513ad8ce5730d75eb20293353e))

# [2.6.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.5.4...v2.6.0) (2022-12-08)


### Features

* Add bootstrap icons. ([21d76e1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/21d76e18b91d075ded072067a12d123b2050a8da))

## [2.5.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.5.3...v2.5.4) (2022-12-06)


### Bug Fixes

* Use local icon instead. ([a623091](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a623091b9f405d401e367935a3e657b72452f228))

## [2.5.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.5.2...v2.5.3) (2022-12-05)


### Bug Fixes

* Fix exports at package.json and docs of table. ([836d2b1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/836d2b12803c5e2d3e3152e744f761e5aaa38fd7))

## [2.5.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.5.1...v2.5.2) (2022-12-04)


### Bug Fixes

* Add exports in package.json. ([c2b4df1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c2b4df1db019c4d7f0c1d12eb6c5e527d038c570))
* Fix default value. ([f14a0c7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f14a0c75055be67fd24733f82f9606f1ee7364ac))
* Fix test. ([4d1a56e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4d1a56e2a6d6f054580f69c089f31c00cef5c705))

## [2.5.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.5.0...v2.5.1) (2022-12-03)


### Bug Fixes

* Add color attribute to dm_mdi. ([00ad870](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/00ad87073ae5fbb159d55438a08adffcd9fdfb18))
* Fix test. ([8490170](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8490170d7becea97061c8842e6274c1dc9174cc0))

# [2.5.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.4.0...v2.5.0) (2022-12-03)


### Features

* Add material design icons community version. ([2ee18ad](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2ee18adbeee0c2cb164f6177752af6e586b2349f))

# [2.4.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.3.6...v2.4.0) (2022-12-01)


### Features

* Add new appbar dm_simple_appbar. ([4101601](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4101601b24f09e9f4133f8c07f423a632025a641))

## [2.3.6](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.3.5...v2.3.6) (2022-11-30)


### Bug Fixes

* Fix @gsmlg/lit. ([ababf12](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ababf129ca57883ed51f3cc87b19885dbf7718ad))

## [2.3.5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.3.4...v2.3.5) (2022-11-30)


### Bug Fixes

* Update @gsmlg/lit. ([5fb7a17](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5fb7a170f4faad16d58b17df1d176a2d07466a6d))

## [2.3.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.3.3...v2.3.4) (2022-11-29)


### Bug Fixes

* Update @gsmlg/lit version. ([311f257](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/311f257f6bfc54f399d06c0b4bd0eabae12c8a11))

## [2.3.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.3.2...v2.3.3) (2022-11-23)


### Bug Fixes

* Add new link storybbok. ([2234b3d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/2234b3dbe84e0c99b48507a6c92c6acd3a1ae2ab))
* Fix format. ([476dd84](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/476dd84ae6b1301e361457a2867ff9a2068d0271))

## [2.3.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.3.1...v2.3.2) (2022-11-15)


### Bug Fixes

* Fix linke style. ([38d2dbf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/38d2dbfde433f647dbd741ab215f438767401b35))

## [2.3.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.3.0...v2.3.1) (2022-11-15)


### Bug Fixes

* Remove elixir 1.11. ([3e59cbc](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3e59cbc8e0c24e7713228ccf20899e6bd7371512))

## [2.2.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.2.2...v2.2.3) (2022-10-14)


### Bug Fixes

* Fix exports issue, bundle has no exports, to switch to using window. ([92f6066](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/92f60663e55c023b6f440da0d12fd1041c50d8ba))

## [2.2.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.2.1...v2.2.2) (2022-10-14)


### Bug Fixes

* Fix js and doc. ([9661b9a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9661b9a671f144d0a26148c92699387b69d766ac))

## [2.2.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.2.0...v2.2.1) (2022-10-12)


### Bug Fixes

* Fix pagination. ([fa8538d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fa8538d1f59036c798a8ea512d893ab4cea4c398))

# [2.2.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.1.4...v2.2.0) (2022-10-08)


### Features

* Add hook to web component. ([eec2b47](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/eec2b4798a549587a3e374a20846ec91cfca4c04))

## [2.1.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.1.3...v2.1.4) (2022-09-28)


### Bug Fixes

* Fix dm_card width and storybook. ([3585d8f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3585d8f047d90b81e50f338a2f2a3ed9ac287647))

## [2.1.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.1.2...v2.1.3) (2022-09-28)


### Bug Fixes

* Fix @gsmlg/lit version. ([7fc6119](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7fc6119e25904a82e868bc6867a3c69a012b1c40))

## [2.1.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.1.1...v2.1.2) (2022-09-24)


### Bug Fixes

* Fix deps. ([b2c5438](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b2c5438074281e44ae945e538c64b6c3fbf91af1))
* Fix deps. ([115db0e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/115db0eb418692479b95e101692eb1f5b7de7b48))

## [2.1.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.1.0...v2.1.1) (2022-09-24)


### Bug Fixes

* Fix use and use :alias. ([d7a12c9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/d7a12c9ddb0d6aa4c5ca858c1ffae4bfb1ad65b5))

# [2.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v2.0.0...v2.1.0) (2022-09-24)


### Bug Fixes

* Fix dm_table. ([689913c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/689913cfe2e58f651c0902856115702f3475a960))


### Features

* Add  action bar. ([6726b25](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6726b257ebecd60446e5a59b0a3f53708035007d))
* Add dm_card. ([f50230a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f50230a58c8d5bbaaed3baadf410eece21b12b8d))
* Add dm_left_menu. ([a48ac09](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a48ac09c5a0feb31223f531365d3a9bcffd9508d))

# [2.0.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.6.3...v2.0.0) (2022-09-21)


### Bug Fixes

* Remove :dry_run. ([a9556d4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/a9556d4f3151df2a42940ac6b3f6fe8a614e900a))


### Features

* BREAKING CHANGE: Project architecture to umbrella project and remove third party web component. ([#4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/4)) ([b6177e0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b6177e025df96702598df3287254b6fd086a8f8c))


### BREAKING CHANGES

* * feat: Change architecture to umbrella project.

* fix: Fix base dev.

* feat: Add live storybook.

* fix: fix test.

* fix: Fix names.

* fix: Fix filename to exs.

* fix: Fix component.

* feat: Update storybook.

* fix: Add class.

* feat: Add tailwind css.

* feat: Add appbar.

* fix: Fix config.

* feat: Add markdown add appbar.

* feat: Add pagination.

* fix: Fix pagination.

* chore: Add CI.

* chore: Fix format.

* fix: Fix test.

* chore: Fix.

* feat: Add use :alias.

* docs: Add README.md

Co-authored-by: Jonathan Gao <gsmlg.com@gmail.com>

## [1.6.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.6.2...v1.6.3) (2022-08-02)


### Bug Fixes

* Fix js. ([7e3ab4d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7e3ab4daca15ae8e2c58aaa83f734edd6507ecf9))

## [1.6.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.6.1...v1.6.2) (2022-08-02)


### Bug Fixes

* Update js. ([fb6a8df](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fb6a8df30760a3494771f91b6e02ef65c5082045))

## [1.6.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.6.0...v1.6.1) (2022-08-01)


### Bug Fixes

* Fix js. ([1fda806](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1fda8063770061a0af6e6cbdc51bd8637000a8ed))

# [1.6.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.5.1...v1.6.0) (2022-07-31)


### Features

* Refactor dm_switch, using my custom element. ([8f911c4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8f911c4d8305e8a13cf25b8a65a22684d0a114bb))

## [1.5.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.5.0...v1.5.1) (2022-04-30)


### Bug Fixes

* Remove useless mwc. ([449e8ae](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/449e8aecf73f81b6e995d84ceed01ae0dec66b37))

# [1.5.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.5...v1.5.0) (2022-04-29)


### Bug Fixes

* Fix toggle. ([44f40b1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/44f40b1481339d65034ed6d8e586566fe3c589d3))
* Move mwc-button to bx-btn. ([fab7d7b](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fab7d7be177356ea6c3d12c1c24de8ae2015dd67))


### Features

* Add table. ([62ff8f7](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/62ff8f73e4e8332ee88a144b3dd206c89b744abe))

## [1.4.5](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.4...v1.4.5) (2022-04-27)


### Bug Fixes

* Fix select. ([c76e9e8](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c76e9e8b8aa6f292ee5ec13645aaf9527bca05b4))

## [1.4.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.3...v1.4.4) (2022-04-27)


### Bug Fixes

* Fix @gsmlg/lit. ([5d6af87](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/5d6af873eb579f4f2f46ada8098f18b7d81f6830))
* Fix build. ([2040626](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/20406260dac1a8982968393af0d8b7cbf88b6e8b))
* Fix date picker. ([38b334c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/38b334cf366faf3c81ddc60409972f7736f0c7d5))
* Fix wx-switch. ([51c46b3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/51c46b38ecf978cdc75dd9d7559f26c6ecd9d4be))
* Update version. ([c4fc629](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c4fc62992c3890638602970a0f64e9ae0167eef5))

## [1.4.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.3...v1.4.4) (2022-04-26)


### Bug Fixes

* Fix build. ([2040626](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/20406260dac1a8982968393af0d8b7cbf88b6e8b))
* Fix date picker. ([38b334c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/38b334cf366faf3c81ddc60409972f7736f0c7d5))
* Fix wx-switch. ([51c46b3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/51c46b38ecf978cdc75dd9d7559f26c6ecd9d4be))
* Update version. ([c4fc629](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c4fc62992c3890638602970a0f64e9ae0167eef5))

## [1.4.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.3...v1.4.4) (2022-04-26)


### Bug Fixes

* Fix build. ([2040626](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/20406260dac1a8982968393af0d8b7cbf88b6e8b))
* Fix date picker. ([38b334c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/38b334cf366faf3c81ddc60409972f7736f0c7d5))
* Update version. ([c4fc629](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c4fc62992c3890638602970a0f64e9ae0167eef5))

## [1.4.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.3...v1.4.4) (2022-04-26)


### Bug Fixes

* Fix build. ([2040626](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/20406260dac1a8982968393af0d8b7cbf88b6e8b))
* Fix date picker. ([38b334c](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/38b334cf366faf3c81ddc60409972f7736f0c7d5))
* Update version. ([c4fc629](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c4fc62992c3890638602970a0f64e9ae0167eef5))

## [1.4.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.3...v1.4.4) (2022-04-26)


### Bug Fixes

* Fix build. ([2040626](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/20406260dac1a8982968393af0d8b7cbf88b6e8b))
* Update version. ([c4fc629](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/c4fc62992c3890638602970a0f64e9ae0167eef5))

## [1.4.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.3...v1.4.4) (2022-04-26)


### Bug Fixes

* Fix build. ([2040626](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/20406260dac1a8982968393af0d8b7cbf88b6e8b))

## [1.4.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.2...v1.4.3) (2022-04-26)


### Bug Fixes

* Fix build. ([82dee27](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/82dee27eb751c758c232da5d71c2cbcdcea1e2ad))

## [1.4.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.1...v1.4.2) (2022-04-26)


### Bug Fixes

* Minify js. ([0391492](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/03914922baa92d0d22f47a9bc791d1304e98abdb))

## [1.4.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.4.0...v1.4.1) (2022-04-25)


### Bug Fixes

* Fix js. ([e494411](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/e494411583122d334acc2838e91db02dc6ea1e03))

# [1.4.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.3.0...v1.4.0) (2022-04-25)


### Bug Fixes

* Remove duplicate form attribute to dm_date_input. ([b91ddaa](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b91ddaaf1dc87d4a63a46eb46f4e2118fba306f2))


### Features

* Change to carbon web component. ([b7a01c8](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b7a01c82cc20edae4748c070cd338e90461aae60))

# [1.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.2.0...v1.3.0) (2022-04-19)


### Bug Fixes

* Fix build. ([53891e8](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/53891e88c9f699c103269897b7af558fc817e89d))
* Set unelevated to dm_submit. ([07f706e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/07f706e5b95c247c6e0af6f6c018c5c6321f1c69))


### Features

* Add form_helper switch. ([713d418](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/713d418a0c0a7faf838ed8ed44849459496d5cbe))

# [1.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.2.0...v1.3.0) (2022-04-19)


### Bug Fixes

* Fix build. ([53891e8](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/53891e88c9f699c103269897b7af558fc817e89d))
* Set unelevated to dm_submit. ([07f706e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/07f706e5b95c247c6e0af6f6c018c5c6321f1c69))


### Features

* Add form_helper switch. ([713d418](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/713d418a0c0a7faf838ed8ed44849459496d5cbe))

# [1.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.2.0...v1.3.0) (2022-04-18)


### Bug Fixes

* Set unelevated to dm_submit. ([07f706e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/07f706e5b95c247c6e0af6f6c018c5c6321f1c69))


### Features

* Add form_helper switch. ([713d418](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/713d418a0c0a7faf838ed8ed44849459496d5cbe))

# [1.3.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.2.0...v1.3.0) (2022-04-17)


### Bug Fixes

* Set unelevated to dm_submit. ([07f706e](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/07f706e5b95c247c6e0af6f6c018c5c6321f1c69))


### Features

* Add form_helper switch. ([713d418](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/713d418a0c0a7faf838ed8ed44849459496d5cbe))

# [1.2.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.1.1...v1.2.0) (2022-04-17)


### Bug Fixes

* Add title to appbar. ([70a6c89](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/70a6c8994278a357efe7c63eab1050b0b28ec123))
* Fix title check. ([1ce9fa1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1ce9fa162b1bd67e13c64c809321a4caa2da9e43))


### Features

* Add dm_top_app_bar component. ([fb292af](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/fb292af1171a85f02ecfb275a1a0aaf72d758721))

## [1.1.1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.1.0...v1.1.1) (2022-04-16)


### Bug Fixes

* Add all js components. ([95bcc5f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/95bcc5f4c7c13dbd03c48c973a2b5b1a23d4fbb9))

# [1.1.0](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.0.0...v1.1.0) (2022-04-16)


### Features

* Add top app bar element. ([6133c66](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/6133c66b509315acc648dd496082c9bd89f2d890))

# 1.0.0 (2022-04-16)


### Bug Fixes

* Avoid warning about jason. ([03182c3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/03182c3bf692502789eaf81446b4c8a6e9daa459))


### Features

* Add pattern to validte email input. ([1f33349](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1f333493f8e4b3e12cf5d720db15458ffb4ee30d))
* First release. ([#1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/1)) ([3294354](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3294354527fb6fc655ca95a41df729ce159673a1))
* Initital package. ([090475d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/090475d2be5b290d9de1f24a4854f3b1d9bfa91a))

# 1.0.0 (2022-04-16)


### Bug Fixes

* Avoid warning about jason. ([03182c3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/03182c3bf692502789eaf81446b4c8a6e9daa459))


### Features

* Add pattern to validte email input. ([1f33349](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1f333493f8e4b3e12cf5d720db15458ffb4ee30d))
* First release. ([#1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/1)) ([3294354](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3294354527fb6fc655ca95a41df729ce159673a1))
* Initital package. ([090475d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/090475d2be5b290d9de1f24a4854f3b1d9bfa91a))

# 1.0.0 (2022-04-16)


### Bug Fixes

* Avoid warning about jason. ([03182c3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/03182c3bf692502789eaf81446b4c8a6e9daa459))


### Features

* Add pattern to validte email input. ([1f33349](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/1f333493f8e4b3e12cf5d720db15458ffb4ee30d))
* First release. ([#1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/1)) ([3294354](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3294354527fb6fc655ca95a41df729ce159673a1))
* Initital package. ([090475d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/090475d2be5b290d9de1f24a4854f3b1d9bfa91a))

# 1.0.0 (2022-04-16)


### Bug Fixes

* Avoid warning about jason. ([03182c3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/03182c3bf692502789eaf81446b4c8a6e9daa459))


### Features

* First release. ([#1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/1)) ([3294354](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3294354527fb6fc655ca95a41df729ce159673a1))
* Initital package. ([090475d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/090475d2be5b290d9de1f24a4854f3b1d9bfa91a))

# 1.0.0 (2022-04-16)


### Features

* First release. ([#1](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues/1)) ([3294354](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3294354527fb6fc655ca95a41df729ce159673a1))
* Initital package. ([090475d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/090475d2be5b290d9de1f24a4854f3b1d9bfa91a))

# [1.0.0-beta.4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.0.0-beta.3...v1.0.0-beta.4) (2022-04-16)


### Bug Fixes

* Fix data-confirm. ([3b14108](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3b14108db7ea175e1adafea8566fa6594b2701f7))
* Optimize link. ([8686596](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/8686596f0adbbecb9c88648fde8c8b072c477970))


### Features

* Add live view link helper, `dm_live_patch`, `dm_live_redirect`. ([323347f](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/323347fa858ab209f3649b50f2fbad9719d9cf2a))

# [1.0.0-beta.3](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.0.0-beta.2...v1.0.0-beta.3) (2022-04-16)


### Bug Fixes

* Fix docs. ([b0806ca](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/b0806cac8b37b653444a584f38ff07698a9e8dab))

# [1.0.0-beta.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.0.0-beta.1...v1.0.0-beta.2) (2022-04-16)


### Bug Fixes

* Fix publish. ([31787ce](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/31787cead0523a33c86f4a13e5f10d330dab9d51))
* Fix test. ([9bd953a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9bd953a3db0170b800abb4afbf906747e540a809))


### Features

* Bundle js. ([f5cf9cd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f5cf9cd927b483a37e5001ef0158b669bdca89b4))

# [1.0.0-beta.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.0.0-beta.1...v1.0.0-beta.2) (2022-04-16)


### Bug Fixes

* Fix test. ([9bd953a](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9bd953a3db0170b800abb4afbf906747e540a809))


### Features

* Bundle js. ([f5cf9cd](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f5cf9cd927b483a37e5001ef0158b669bdca89b4))

# 1.0.0-beta.1 (2022-04-16)


### Bug Fixes

* Finish test. ([7a72801](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7a72801f76ff8e660204c328813fa6e692b443fc))
* Fix errors. ([eb15385](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/eb15385d84f40acd116de9d95f354773b7671afc))
* Fix import. ([4277eaf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4277eaf6a872dc1888ed15f471eb476a3c909046))
* Fix issue. ([3523dc9](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/3523dc99ca995589a8634b7a232fcd2db4f4ea5a))
* Fix link_attributes. ([9d55077](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9d5507726de36dacb60414353e139dbee8fdca77))
* Format code. ([7a37b11](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7a37b11abe484a3e5cf669e67a042d4afc961a84))
* Optimize password. ([f763731](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/f7637317a3813a0f5077b34c095f023024aa5c82))


### Features

* Add `dm_remark`. ([9714a45](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9714a454aefa5a51964242a3166f8a387e814908))
* Add phoenix_html to deps. ([d8ea8a4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/d8ea8a4903018bd29432f365e4c5f4b283158f43))
* Initital package. ([090475d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/090475d2be5b290d9de1f24a4854f3b1d9bfa91a))
* Into beta, optimize input, start make it more reliable and more useful. ([adf4133](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/adf4133d02ab15182ac0b0b83b8f20d8ca23f894))
* Set web compoent form. ([ba3bf68](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ba3bf6883491945f3d3bd095f2fa3b47f091384c))

# [1.0.0-alpha.2](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/compare/v1.0.0-alpha.1...v1.0.0-alpha.2) (2022-04-16)


### Features

* Add `dm_remark`. ([9714a45](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9714a454aefa5a51964242a3166f8a387e814908))

# 1.0.0-alpha.1 (2022-04-15)


### Bug Fixes

* Finish test. ([7a72801](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7a72801f76ff8e660204c328813fa6e692b443fc))
* Fix import. ([4277eaf](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/4277eaf6a872dc1888ed15f471eb476a3c909046))
* Fix link_attributes. ([9d55077](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/9d5507726de36dacb60414353e139dbee8fdca77))
* Format code. ([7a37b11](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/7a37b11abe484a3e5cf669e67a042d4afc961a84))


### Features

* Add phoenix_html to deps. ([d8ea8a4](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/d8ea8a4903018bd29432f365e4c5f4b283158f43))
* Initital package. ([090475d](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/090475d2be5b290d9de1f24a4854f3b1d9bfa91a))
* Set web compoent form. ([ba3bf68](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/commit/ba3bf6883491945f3d3bd095f2fa3b47f091384c))

# Changelog
