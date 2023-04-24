#' Fit a Probabilistic Matching Model using Naive Bayes + E.M.
#'
#' @param X an integer matrix of similarities. Must go from 0 (the most
#' disagreement) to the maximum without any "gaps" or unused levels. As an
#' example, a column with values 0,1,2,3 is a valid column, but 0,1,2,4 is not
#' as three is omitted
#'
#' @param g a vector of initial guesses that are iteratively improved using the
#' EM algorithm (my personal approach is to guess at logistic regression
#' coefficients and use them to create the intitial probability guesses)
#'
#' @param tol tolerance in the sense of the infinity norm. i.e. how close the
#' parameters have to be between iterations before the EM algorithm terminates.
#'
#' @param max_iter iterations after which the algorithm will error out if it
#' has not converged.
#'
#' @return a vector of probabilities representing the posterior probability
#' each record pair is a match.
#'
#' @examples
#'
#' inv_logit <- function (x) {
#'    exp(x)/(1+exp(x))
#'}
#'n <- 10^6
#'d <- 1:n %% 5 == 0
#'X <- cbind(
#'         as.integer(ifelse(d, runif(n)<.8, runif(n)<.2)),
#'         as.integer(ifelse(d, runif(n)<.9, runif(n)<.2)),
#'         as.integer(ifelse(d, runif(n)<.7, runif(n)<.2)),
#'         as.integer(ifelse(d, runif(n)<.6, runif(n)<.2)),
#'         as.integer(ifelse(d, runif(n)<.5, runif(n)<.2)),
#'         as.integer(ifelse(d, runif(n)<.1, runif(n)<.9)),
#'         as.integer(ifelse(d, runif(n)<.1, runif(n)<.9)),
#'         as.integer(ifelse(d, runif(n)<.8, runif(n)<.01))
#'         )
#'
#' # inital guess at class assignments based on
#' # a hypothetical logistic regression. Should be based on domain knowledge.
#'
#'x_sum <- rowSums(X)
#'g <- inv_logit((x_sum - mean(x_sum))/sd(x_sum))
#'
#' out <- em_link(X, g,tol=.0001, max_iter = 100)
#'
#' @export
em_link <- function (X,g, tol = 10^-6, max_iter = 10^3) {
    stopifnot("initial guesses must be valid probabilities (greater than 0 and less than 1)"
              = all(g < 1 & g > 0))

    rust_em_link(X,g, tol, max_iter)
}
