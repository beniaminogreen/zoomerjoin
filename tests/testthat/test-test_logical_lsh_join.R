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

test_that("jaccard_inner_join works on tiny dataset", {
    capture_messages(
        test <- jaccard_inner_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
    )

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2))
    expect_identical(sort(test$id_2), c(1,2))

})
test_that("jaccard_full_join works on tiny dataset", {
    capture_messages(
        test <- jaccard_full_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
    )

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2,3))
    expect_identical(sort(test$id_2), c(1,2,3))

})
test_that("jaccard_left_join works on tiny dataset", {
    capture_messages(
        test <- jaccard_left_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
    )

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2,3))
    expect_identical(sort(test$id_2), c(1,2))

})
test_that("jaccard_right_join works on tiny dataset", {
    capture_messages(
        test <- jaccard_right_join(dataset_1, dataset_2, threshold=.6, n_bands=300)
                     )


    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2))
    expect_identical(sort(test$id_2), c(1,2,3))
})

test_that("jaccard_inner_join gives same results as stringdist_inner_join", {
    for (i in 1:20) {
    capture_messages({

    zoomer_join_out <- jaccard_inner_join(names_df, misspelled_name_df, n_gram_width = 1, threshold = .9, n_bands=150, band_width = 5) %>%
            arrange(id_1, id_2)

    stringdist_join_out <- stringdist_inner_join(names_df, misspelled_name_df, method="jaccard", max_dist=.1) %>%
        arrange(id_1, id_2)

    })

    expect_true(all.equal(zoomer_join_out, stringdist_join_out))

    zoomer_join_out <- jaccard_inner_join(names_df, misspelled_name_df, n_gram_width = 1, threshold = .9, n_bands=150, band_width = 5, similarity_column = "sim")
    expect_equal(zoomer_join_out$sim, jaccard_similarity(zoomer_join_out$name.x, zoomer_join_out$name.y, ngram_width=1))
    }
})

test_that("Blocking Functionality works correctly for jaccard_inner_join", {
      joined_block_on_one <- jaccard_inner_join(iris, iris, by = c("Species"), block_by = "Petal.Width", n_bands = 190)

      expect_equal(joined_block_on_one$Petal.Width.y, joined_block_on_one$Petal.Width.x)

      joined_block_on_two <- jaccard_inner_join(iris, iris, by = c("Species"), block_by = c("Petal.Width", "Sepal.Width"), n_bands = 190)

      expect_equal(joined_block_on_two$Petal.Width.y, joined_block_on_two$Petal.Width.x)
      expect_equal(joined_block_on_two$Sepal.Width.y, joined_block_on_two$Sepal.Width.x)
})

test_that("seed works for jaccard joins", {
    for (i in 1:15) {
        set.seed(i)
        suppressWarnings(
            a <- jaccard_inner_join(
                          names_df, misspelled_name_df,
                          by  = "name",
                          n_gram_width = 1, threshold = .3,
                          n_bands = 1, band_width = 5
                          ) %>%
            arrange(id_1) %>%
            pull(id_1)
        )

        set.seed(i)
        suppressWarnings(
            b <- jaccard_inner_join(
                          names_df, misspelled_name_df,
                          by  = "name",
                          n_gram_width = 1, threshold = .3,
                          n_bands = 1, band_width = 5
                          ) %>%
            arrange(id_1) %>%
            pull(id_1)
        )

        expect_equal(a,b)
    }
})


