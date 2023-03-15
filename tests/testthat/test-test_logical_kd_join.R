test_that("kd_join_core works on toy datasets", {
    for (i in 1:30) {
    capture_messages({

        n <- 2000
        X_1 <- matrix(rnorm(n*2), nrow=n)

        X_2 <- X_1 + matrix(rnorm(n*2,0,.0000001), nrow=n)
        X_2 <- rbind(X_2, matrix(rnorm(10*2), nrow=10))

        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)


        X_1$id_1 <- 1:n
        X_2$id_2 <- 1:(n+10)

        inner_join_out <- kd_inner_join(X_1, X_2, threshold =.00005)

        expect_equal(nrow(inner_join_out), 2000)

        expect_true(all(inner_join_out$id_1 %in% 1:2000))
        expect_true(all(inner_join_out$id_2 %in% 1:2000))
        expect_true(all(inner_join_out$id_1 == inner_join_out$id_2))

        left_join_out <- kd_left_join(X_1, X_2, threshold =.00005)

        expect_true(all(left_join_out$id_1 %in% 1:2000))
        expect_true(all(left_join_out$id_2 %in% 1:2000))
        expect_true(all(left_join_out$id_1 == inner_join_out$id_2))
        expect_equal(nrow(left_join_out), 2000)

        right_join_out <- kd_right_join(X_1, X_2, threshold =.00005)

        expect_equal(nrow(right_join_out), 2010)
        expect_true(all(right_join_out$id_1 %in% c(1:2000,NA), na.rm =T))
        expect_true(all(right_join_out$id_2 %in% 1:2010))

        outer_join_out <- kd_anti_join(X_1, X_2, threshold =.00005)
        expect_equal(nrow(outer_join_out), 10)
        expect_true(all(outer_join_out$id_2 %in% 2000:2010))
        expect_true(all(is.na(outer_join_out$id_1)))

        full_join_out <- kd_full_join(X_1, X_2, threshold =.00005)
        expect_equal(nrow(full_join_out), 2010)
        expect_true(all(full_join_out$id_2 %in% 1:2010))
        expect_true(all(full_join_out$id_1 %in% c(1:2000, NA)))
    })
    }
})
