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
        expect_error(lsh_inner_join(a,b, threshold = 20), regexp = "threshold.* between")
})

test_that("Validates n_bands is positive", {
        expect_error(lsh_inner_join(a,b, n_bands =  -5), regexp = "n_bands")
})

test_that("Validates band_width is positive", {
       expect_error(lsh_inner_join(a,b, band_width = -5), regexp = "band_width")
})

test_that("validates n_gram_width is positive", {
        expect_error(lsh_inner_join(a,b, n_gram_width = -5), regexp = "n_gram_width")
})

test_that("validates mode is correct", {
        expect_error(kd_join_core(a,b, by = "string", mode="000000000"))
})

test_that("Throws error when no shared columns", {
        a2 <- a
        names(a2) <- c('ajaaj', 'ahah')

        expect_error(lsh_inner_join(a2,b), regexp = "Can't Determine")
})

test_that("Match Col Must be in the dataset and of length one", {
        a2 <- a
        names(a2) <- c('ajaaj', 'ahah')

        expect_error(lsh_inner_join(a2,a2, by = c('ajaaj', "ahah")), regexp = "length 1")
        expect_error(lsh_inner_join(a2,b, by = c('a'="b")), regexp = "by_a")
        expect_error(lsh_inner_join(a,b, by = c('string'="b")), regexp = "by_b")
})

