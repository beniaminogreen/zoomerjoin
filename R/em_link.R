#' Fit a Probabilistic Matching Model using Naive Bayes + E.M.
#'
#' A Rust implementation of the Naive Bayes / Fellegi-Sunter model of record
#' linkage as detailed in the article "Using a Probabilistic Model to Assist
#' Merging of Large-Scale Administrative Records" by Enamorado, Fifield and
#' Imai (2019). Takes an integer matrix describing the similarities between
#' each possible pair of observations, and a vector of initial guesses of the
#' probability each pair is a match (these can either be set from domain
#' knowledge, or one can hand-label a subset of the data and leave the rest as
#' p=.5). Iteratively refines these guesses using the Expectation Maximization
#' algorithm until an optima is reached. for more details, see
#' \doi{10.1017/S0003055418000783}.
#'
#'
#' @param X an integer matrix of similarities. Must go from 0 (the most
#' disagreement) to the maximum without any "gaps" or unused levels. As an
#' example, a column with values 0,1,2,3 is a valid column, but 0,1,2,4 is not
#' as three is omitted
#'
#' @param g a vector of initial guesses that are iteratively improved using the
#' EM algorithm (my personal approach is to guess at logistic regression
#' coefficients and use them to create the intitial probability guesses). This
#' is chosen to avoid the model getting stuck in a local optimum, and to avoid
#' the problem of label-switching, where the labels for matches and non-matches
#' are reversed.
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
#' # inital guess at class assignments based on # a hypothetical logistic
#' # regression. Should be based on domain knowledge, or a handful of hand-coded
#' # observations.
#'
#'x_sum <- rowSums(X)
#'g <- inv_logit((x_sum - mean(x_sum))/sd(x_sum))
#'
#' out <- em_link(X, g,tol=.0001, max_iter = 100)
#'
#' @export
em_link <- function (X,g, tol = 10^-6, max_iter = 10^3) {

    stopifnot("There can be no NA's in X (but you can add NA as its own agreement level)"
              = !any(is.na(X)))

    stopifnot("initial guesses must be valid probabilities (greater than 0 and less than 1)"
              = all(g < 1 & g > 0))


    rust_em_link(X,g, tol, max_iter)
}
