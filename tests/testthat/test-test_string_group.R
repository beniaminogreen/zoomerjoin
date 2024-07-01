test_that("string_group dedups string correctly", {
  skip_if_not_installed("igraph")
  n_groups <- purrr::map_dbl(1:30, function(x) {
    string <- c("beniamino", "jack", "benjamin", "beniamin", "jacky")
    dplyr::n_distinct(jaccard_string_group(string, n_bands = 190, threshold = .2))
  })


  n_groups <- purrr::map_dbl(1:30, function(x) {
    string <- c("new haven", "new york", "chicago", "newy york")
    dplyr::n_distinct(jaccard_string_group(string, n_bands = 190, threshold = .2))
  })
  expect_equal(median(n_groups), 3)
})
