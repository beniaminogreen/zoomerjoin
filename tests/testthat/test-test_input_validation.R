library(tibble)
a <- tribble(
  ~id_1, ~string,
  1, "beniamino green",
  2, "ben green",
  3, "jack green"
)

b <- tribble(
  ~id_2, ~string,
  1, "teniamino green",
  2, "beni green",
  3, "gibberish"
)

test_that("Validates Threshold is between 0 and 1", {
  expect_error(jaccard_inner_join(a, b, threshold = 20), regexp = "threshold.* between")
})

test_that("Validates n_bands is positive", {
  expect_error(jaccard_inner_join(a, b, n_bands = -5, threshold = .99), regexp = "n_bands")
})

test_that("Validates band_width is positive", {
  expect_error(jaccard_inner_join(a, b, band_width = -5, threshold = .99), regexp = "band_width")
})

test_that("validates n_gram_width is positive", {
  expect_error(jaccard_inner_join(a, b, n_gram_width = -5, threshold = .99), regexp = "n_gram_width")
})

test_that("Throws error when no shared columns", {
  a2 <- a
  names(a2) <- c("ajaaj", "ahah")

  expect_error(jaccard_inner_join(a2, b, threshold = .99), regexp = "Can't Determine")
})

test_that("Match Col Must be in the dataset and of length one", {
  a2 <- a
  names(a2) <- c("ajaaj", "ahah")

  expect_error(jaccard_inner_join(a2, a2, by = c("ajaaj", "ahah"), threshold = .99), regexp = "length 1")
  expect_error(jaccard_inner_join(a2, b, by = c("a" = "b"), threshold = .99), regexp = "by_a")
  expect_error(jaccard_inner_join(a, b, by = c("string" = "b"), threshold = .99), regexp = "by_b")
})

test_that("Jaccard: using dplyr::join_by() in the 'by' argument works", {
  expect_identical(
    jaccard_inner_join(a, b, by = "string", band_width = 2),
    jaccard_inner_join(a, b, by = dplyr::join_by(string), band_width = 2)
  )

  a2 <- b
  names(a2) <- c("id_2", "foobar")
  expect_identical(
    jaccard_inner_join(a, a2, by = c("string" = "foobar"), band_width = 2),
    jaccard_inner_join(a, a2, by = dplyr::join_by(string == foobar), band_width = 2)
  )
})

test_that("Euclidean: using dplyr::join_by() in the 'by' argument works", {
  n <- 10

  X_1 <- matrix(c(seq(0, 1, 1 / (n - 1)), seq(0, 1, 1 / (n - 1))), nrow = n)
  X_2 <- X_1 + .0000001

  X_1 <- as.data.frame(X_1)
  X_2 <- as.data.frame(X_2)

  X_1$id_1 <- 1:n
  X_2$id_2 <- 1:n

  expect_identical(
    {
      res1 <- euclidean_inner_join(X_1, X_2, by = c("V1", "V2"), threshold = .00005)
      res1[order(res1$id_1), ]
    },
    {
      res1 <- euclidean_inner_join(X_1, X_2, by = dplyr::join_by(V1, V2), threshold = .00005)
      res1[order(res1$id_1), ]
    },
    ignore_attr = TRUE # ignore row numbers
  )

  names(X_2) <- c("Var1", "Var2", "id_2")
  expect_identical(
    {
      res1 <- euclidean_inner_join(X_1, X_2, by = c("V1" = "Var1", "V2" = "Var2"), threshold = .00005)
      res1[order(res1$id_1), ]
    },
    {
      res1 <- euclidean_inner_join(X_1, X_2, by = dplyr::join_by(V1 == Var1, V2 == Var2), threshold = .00005)
      res1[order(res1$id_1), ]
    },
    ignore_attr = TRUE # ignore row numbers
  )
})
