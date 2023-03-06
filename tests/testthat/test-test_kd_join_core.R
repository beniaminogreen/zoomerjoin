test_that("kd_join_core works on toy datasets", {
    for (i in 1:20) {
    capture_messages({
        n <- 2000
        X_1 <- matrix(rnorm(n*2), nrow=n)
        X_2 <- X_1 + matrix(rnorm(n*2,0,.000001), nrow=n)
        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)

        expect_equal(nrow(kd_join_core(X_1, X_2, radius=.00005)), 2000)
    })
    }
})



