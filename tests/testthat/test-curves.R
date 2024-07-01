test_that("euclidean curve", {
  skip_if_not_installed("vdiffr")
  vdiffr::expect_doppelganger(
    "Basic Euclidean curve",
    euclidean_curve(20, 5, r = 0.5)
  )
})

test_that("jaccard curve", {
  expect_error(
    jaccard_curve(c(20, 10), 1),
    "single integer"
  )
  expect_error(
    jaccard_curve(1, c(20, 10)),
    "single integer"
  )
  skip_if_not_installed("vdiffr")
  vdiffr::expect_doppelganger(
    "Basic Jaccard curve",
    jaccard_curve(20, 5)
  )
})
