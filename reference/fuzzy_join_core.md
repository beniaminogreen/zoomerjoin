# Perform a Fuzzy-Join With an Arbitrary Distance Metric

Code used by zoomerjoin to perform dplyr-style joins. Users wishing to
write their own joining functions can extend zoomerjoin's functionality
by writing joining functions to use with `fuzzy_join_core`.

## Usage

``` r
fuzzy_join_core(
  a,
  b,
  by,
  join_func,
  mode,
  block_by = NULL,
  similarity_column = NULL,
  ...
)
```

## Arguments

- a, b:

  The two dataframes to join.

- by:

  A named vector indicating which columns to join on. Format should be
  the same as dplyr:
  `by = c("column_name_in_df_a" = "column_name_in_df_b")`, but two
  columns must be specified in each dataset (x column and y column).
  Specification made with
  [`dplyr::join_by()`](https://dplyr.tidyverse.org/reference/join_by.html)
  are also accepted.

- join_func:

  the joining function responsible for performing the join.

- mode:

  the dplyr-style type of join you want to perform

- block_by:

  A named vector indicating which columns to 'block' (perform exact
  joining) on. Format should be the same as dplyr:
  `by = c("column_name_in_df_a" = "column_name_in_df_b")`, but two
  columns must be specified in each dataset (x column and y column).
  Specification made with
  [`dplyr::join_by()`](https://dplyr.tidyverse.org/reference/join_by.html)
  are also accepted.

- similarity_column:

  An optional character vector. If provided, the data frame will contain
  a column with this name giving the similarity between the two fields.
  Extra column will not be present if anti-joining.

- ...:

  Other parameters to be passed to the joining function
