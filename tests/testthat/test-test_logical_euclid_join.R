test_that("euclidean_join_core works on toy datasets", {
    capture_messages({

        n <- 2000
        X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
        X_2 <- X_1 + .000000000001
        X_2 <- rbind(X_2, matrix(rep(c(2,2),10), nrow=10))

        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)

        X_1$id_1 <- 1:n
        X_2$id_2 <- 1:(n+10)

        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)

        inner_join_out <- euclidean_inner_join(X_1, X_2, threshold =.00005)

        expect_equal(nrow(inner_join_out), 2000)
        expect_true(all(inner_join_out$id_1 %in% 1:2000))
        expect_true(all(inner_join_out$id_2 %in% 1:2000))
        expect_true(all(inner_join_out$id_1 == inner_join_out$id_2))

        left_join_out <- euclidean_left_join(X_1, X_2, threshold =.000005, band_width = 1)


        expect_true(all(left_join_out$id_1 %in% 1:2000))
        expect_true(all(left_join_out$id_2 %in% 1:2000))
        expect_true(all(left_join_out$id_1 == left_join_out$id_2))
        expect_equal(nrow(left_join_out), 2000)

        right_join_out <- euclidean_right_join(X_1, X_2, threshold =.00005)
        expect_equal(nrow(right_join_out), 2010)
        expect_true(all(right_join_out$id_1 %in% c(1:2000,NA), na.rm =T))
        expect_true(all(right_join_out$id_2 %in% 1:2010))

        outer_join_out <- euclidean_anti_join(X_1, X_2, threshold =.00005)
        expect_equal(nrow(outer_join_out), 10)
        expect_true(all(outer_join_out$id_2 %in% 2000:2010))
        expect_true(all(is.na(outer_join_out$id_1)))

        full_join_out <- euclidean_full_join(X_1, X_2, threshold =.00005)
        expect_equal(nrow(full_join_out), 2010)
        expect_true(all(full_join_out$id_2 %in% 1:2010))
        expect_true(all(full_join_out$id_1 %in% c(1:2000, NA)))

    })
})


test_that("set.seed works with Euclidean join", {

        set.seed(1)
        n <- 20
        X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
        X_2 <- X_1 + .1
        X_2 <- rbind(X_2, matrix(rep(c(2,2),10), nrow=10))
        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)
        X_1$id_1 <- 1:n
        X_2$id_2 <- 1:(n+10)
        X_1 <- as.data.frame(X_1)
        X_2 <- as.data.frame(X_2)

        for (i in 1:20){
            set.seed(i)
            suppressWarnings(out_1 <- euclidean_inner_join(X_1, X_2, threshold =5))
            set.seed(i)
            suppressWarnings(out_2 <- euclidean_inner_join(X_1, X_2, threshold =5))
            expect_equal(colSums(out_1), colSums(out_2))
        }

})
