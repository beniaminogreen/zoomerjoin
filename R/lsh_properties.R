#' Performance Plots for LSH functions
#'
#' @param n_bands: The number of LSH bands calculated
#'
#' @param band_width: The number of hashes in each band
#'
#' @return A plot showing the probability a pair is proposed as a match, given
#' the Jaccard similarity of the two items.
#'
#' @export
lsh_curve <- function(n_bands, band_width) {
    similarity <- seq(0,1,.005)

    probs <- 1-(1-similarity^band_width)^n_bands

    plot(similarity, probs,
         xlab = "Jaccard Similarity of Two Strings",
         ylab = "Probability that Strings are Proposed as a Match",
         type="l",
         col = "blue"
    )

}
