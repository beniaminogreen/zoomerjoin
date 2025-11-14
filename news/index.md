# Changelog

## zoomerjoin 0.2.1

CRAN release: 2025-04-13

## zoomerjoin 0.2.0

CRAN release: 2024-09-24

## zoomerjoin 0.1.5

CRAN release: 2024-07-02

### New features

- Several performance improvements
  ([\#101](https://github.com/beniaminogreen/zoomerjoin/issues/101),
  [\#104](https://github.com/beniaminogreen/zoomerjoin/issues/104)).
- Added support for joining based on hamming distance
  ([\#100](https://github.com/beniaminogreen/zoomerjoin/issues/100)).
- Bumped `extendr` to v0.7.0
  ([\#121](https://github.com/beniaminogreen/zoomerjoin/issues/121))

### Bug fixes

- Fixed bug where when `clean = TRUE`, strings were not coerced to lower
  case
  ([\#105](https://github.com/beniaminogreen/zoomerjoin/issues/105)).
- Fix argument `progress`, was inoperative
  ([\#107](https://github.com/beniaminogreen/zoomerjoin/issues/107)).

## zoomerjoin 0.1.4

CRAN release: 2024-01-31

- Submitted Package to CRAN
- Add support for new
  [`join_by()`](https://dplyr.tidyverse.org/reference/join_by.html)
  syntax
- Added a `NEWS.md` file to track changes to the package.
