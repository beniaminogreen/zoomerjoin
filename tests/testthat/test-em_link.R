test_that("Naive Bayes Model Achieves > 95 perecent accuracy on toy dataset", {
  inv_logit <- function(x) {
    exp(x) / (1 + exp(x))
  }

  for (i in 1:10) {
    n <- 10^5
    d <- 1:n %% 5 == 0
    X <- cbind(
      as.integer(ifelse(d, runif(n) < .8, runif(n) < .2)),
      as.integer(ifelse(d, runif(n) < .9, runif(n) < .2)),
      as.integer(ifelse(d, runif(n) < .7, runif(n) < .2)),
      as.integer(ifelse(d, runif(n) < .6, runif(n) < .2)),
      as.integer(ifelse(d, runif(n) < .5, runif(n) < .2)),
      as.integer(ifelse(d, runif(n) < .1, runif(n) < .9)),
      as.integer(ifelse(d, runif(n) < .1, runif(n) < .9)),
      as.integer(ifelse(d, runif(n) < .8, runif(n) < .01))
    )

    x_sum <- rowSums(X)
    g <- inv_logit((x_sum - mean(x_sum)) / sd(x_sum))
    out <- em_link(X, g, tol = .0001, max_iter = 100)

    confusion_vector <- c(prop.table(table(out > .5, d)))
    # Expect classifier gets better than  97 percent accurately reliably on toy example
    expect_true((confusion_vector[1] + confusion_vector[4]) > .97)
  }
})
