capture_messages({
    require(tibble)
    require(dplyr)
    require(babynames)
    require(fuzzyjoin)
    require(stringdist)
})

dataset_1 <- tribble(
                     ~id_1, ~string,
                     1, "beniamino green",
                     2, "ben green",
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
    idx <- sample(1:nch,1)
    substr(name,idx,idx) <- "*"
    name
}
misspell <- Vectorize(misspell)

names_df <- tibble(
    name = tolower(unique(babynames$name)),
    id_1 = 1:n_distinct(babynames$name)
       ) %>%
filter(nchar(name)>9) %>%
filter(row_number()<500)

misspelled_name_df <- names_df %>%
    rename(id_2 = id_1) %>%
    mutate(
           name = misspell(name),
    )

test_that("lsh_inner_join works on tiny dataset", {
    capture_messages(
        test <- lsh_inner_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
    )

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2))
    expect_identical(sort(test$id_2), c(1,2))

})
test_that("lsh_full_join works on tiny dataset", {
    capture_messages(
        test <- lsh_full_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
    )

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2,3))
    expect_identical(sort(test$id_2), c(1,2,3))

})
test_that("lsh_left_join works on tiny dataset", {
    capture_messages(
        test <- lsh_left_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
    )

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2,3))
    expect_identical(sort(test$id_2), c(1,2))

})
test_that("lsh_right_join works on tiny dataset", {
    capture_messages(
        test <- lsh_right_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
                     )


    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2))
    expect_identical(sort(test$id_2), c(1,2,3))
})

test_that("lsh_inner_join gives same results as stringdist_inner_join", {
    for (i in 1:20) {
    capture_messages({
        zoomer_join_out <- lsh_inner_join(names_df, misspelled_name_df, n_gram_width = 1, threshold = .9, n_bands=150, band_width = 5) %>%
            arrange(id_1)

    stringdist_join_out <- stringdist_inner_join(names_df, misspelled_name_df, method="jaccard", max_dist=.1) %>%
        arrange(id_1)
    })

    expect_true(all_equal(zoomer_join_out, stringdist_join_out))

    }
})



