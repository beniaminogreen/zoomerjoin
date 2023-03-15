test_that("kd_join_core works on toy datasets", {
    capture_messages({
        n <- 200
        X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
        X_2 <- X_1 + .000000000001

        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)

        X_1$id_1 <- 1:n
        X_2$id_2 <- 1:n

        join_out <- kd_join_core(X_1, X_2, threshold =.000005)

        expect_true(all(join_out$id_1 == join_out$id_2))

        expect_equal(nrow(join_out), 200)
    })
})



