#' Fit a Probabilistic Matching Model using Naive Bayes + E.M.
#'
#' @param X a matrix of similarities
#' @param g a vector of initial guesses
#' @param tol tolerance in the sense of the infinity norm. i.e.
#'
#' @param max_iter iterations after which the algorithm will error out if it has not converged
#' @return a vector of probabilities representing the posterior probability
#' each record pair is a match.
#'
#' @export
em_link <- function (X,g, tol = 10^-6, max_iter = 10^3) {
    stopifnot("initial guesses must be valid probabilities (greater than 0 and less than 1)"
              = all(g < 1 & g > 0))

    rust_em_link(X,g, tol, max_iter)
}
