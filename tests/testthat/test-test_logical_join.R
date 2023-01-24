library(tibble)
dataset_1 <- tribble(
                     ~id_1, ~string,
                     1, "beniamino green",
                     2, "ben green",
                     3, "jack green"
)

dataset_2 <- tribble(
                     ~id_2, ~string,
                     1, "teniamino green",
                     2, "beni green",
                     3, "gibberish"
)

test_that("lsh_inner_join works", {
    test <- lsh_inner_join(dataset_1, dataset_2, threshold=.6)

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2))
    expect_identical(sort(test$id_2), c(1,2))

})
test_that("lsh_left_join works", {
    test <- lsh_left_join(dataset_1, dataset_2, threshold=.6)

    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2,3))
    expect_identical(sort(test$id_2), c(1,2))

})
test_that("lsh_right_join works", {
    test <- lsh_right_join(dataset_1, dataset_2, threshold=.6)


    expect_true(all(test$id_1 == test$id_2, na.rm=T))

    expect_identical(sort(test$id_1), c(1,2))
    expect_identical(sort(test$id_2), c(1,2,3))
})


