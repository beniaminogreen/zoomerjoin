test_that("kd_join_core works on toy datasets", {
    for (i in 1:30) {
    capture_messages({
        n <- 2000
        X_1 <- matrix(rnorm(n*2), nrow=n)
        X_2 <- X_1 + matrix(rnorm(n*2,0,.000001), nrow=n)
        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)

        X_1$id_1 <- 1:n
        X_2$id_2 <- 1:n

        join_out <- kd_join_core(X_1, X_2, threshold =.00005)

        expect_true(all(join_out$id_1 == join_out$id_2))

        expect_equal(nrow(join_out), 2000)
    })
    }
})



