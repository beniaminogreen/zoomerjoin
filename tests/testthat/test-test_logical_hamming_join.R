capture_messages({
  require(tibble)
  require(dplyr)
  require(babynames)
  require(fuzzyjoin)
  require(stringdist)
  require(stringr)
})

dataset_1 <- tribble(
  ~id_1, ~string,
  1, "beniamino green",
  2, "ben  green",
  3, "jack green"
) %>%
  as.data.frame()
dataset_2 <- tribble(
  ~id_2, ~string,
  1, "teniamino green",
  2, "beni green",
  3, "gibberish"
) %>%
  as.data.frame()

misspell <- function(name) {
  nch <- nchar(name)
  idx <- sample(1:(nch-1), 1)
  substr(name, idx, idx) <- "*"
  name
}
misspell <- Vectorize(misspell)

names_df <- tibble(
  name = str_pad(tolower(unique(babynames$name)), 15, "right"),
  id_1 = 1:n_distinct(babynames$name)
) %>%
  filter(nchar(name) > 9) %>%
  filter(row_number() < 500)

misspelled_name_df <- names_df %>%
  rename(id_2 = id_1) %>%
  mutate(
    name = str_pad(misspell(name), 15, "right")
  )

test_that("hamming_inner_join works on tiny dataset", {
  capture_messages(
    test <- hamming_inner_join(dataset_1, dataset_2, threshold = 3, band_width = 1, n_bands = 300)
  )

  expect_true(all(test$id_1 == test$id_2, na.rm = T))

  expect_identical(sort(test$id_1), c(1, 2))
  expect_identical(sort(test$id_2), c(1, 2))
})

test_that("hamming_full_join works on tiny dataset", {
  capture_messages(
    test <- hamming_full_join(dataset_1, dataset_2, threshold = 3, band_width = 1, n_bands = 300)
  )

  expect_true(all(test$id_1 == test$id_2, na.rm = T))

  expect_identical(sort(test$id_1), c(1, 2, 3))
  expect_identical(sort(test$id_2), c(1, 2, 3))
})

test_that("hamming_left_join works on tiny dataset", {
  capture_messages(
    test <- hamming_left_join(dataset_1, dataset_2, threshold = 3, band_width = 1,  n_bands = 300)
  )

  expect_true(all(test$id_1 == test$id_2, na.rm = T))

  expect_identical(sort(test$id_1), c(1, 2, 3))
  expect_identical(sort(test$id_2), c(1, 2))
})

test_that("hamming_right_join works on tiny dataset", {
  capture_messages(
    test <- hamming_right_join(dataset_1, dataset_2, threshold = 3, band_width = 1,  n_bands = 300)
  )


  expect_true(all(test$id_1 == test$id_2, na.rm = T))

  expect_identical(sort(test$id_1), c(1, 2))
  expect_identical(sort(test$id_2), c(1, 2, 3))
})

test_that("jaccard_inner_join gives same results as stringdist_inner_join", {
  for (i in 1:20) {
    capture_messages({

      zoomer_join_out <- hamming_inner_join(names_df, misspelled_name_df, threshold = 3, n_bands = 2400, band_width = 1) %>%
        arrange(id_1, id_2)
      stringdist_join_out <- stringdist_inner_join(names_df, misspelled_name_df, method = "hamming", max_dist = 3) %>%
        arrange(id_1, id_2)

    })

    expect_true(all.equal(zoomer_join_out, stringdist_join_out))
  }
})


test_that("seed works for hamming joins", {
  for (i in 1:15) {
    set.seed(i)
    suppressWarnings(
      a <- hamming_inner_join(
        names_df, misspelled_name_df,
        by = "name",
        threshold = .3,
        n_bands = 1, band_width = 5
      ) %>%
        arrange(id_1) %>%
        pull(id_1)
    )

    set.seed(i)
    suppressWarnings(
      b <- hamming_inner_join(
        names_df, misspelled_name_df,
        by = "name",
        threshold = .3,
        n_bands = 1, band_width = 5
      ) %>%
        arrange(id_1) %>%
        pull(id_1)
    )

    expect_equal(a, b)
  }
})
