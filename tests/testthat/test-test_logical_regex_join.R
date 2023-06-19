capture_messages({
    require(tibble)
    require(fuzzyjoin)
})

devtools::load_all()

hashtag_regex <- "\\#[a-zA-Z][0-9a-zA-Z_]*"
left_test <- tibble(x=c("hey", "this is a #test", "#test1 #test2", "#testy"))
left_test$id <- 1:nrow(left_test)

right_test <- tibble(x=c("hey", "#test", "abcde #test1 #test2", "#testy"))
right_test$id <- 1:nrow(right_test)

test_that("regex_inner_join works on small dataset", {
    test <- re_inner_join(left_test, right_test, hashtag_regex, by = "x")

    expect_identical(sort(test$`id.x`), c(2L,3L,4L))
    expect_identical(sort(test$`id.y`), c(2L,3L,4L))
})

