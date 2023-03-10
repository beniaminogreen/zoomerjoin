#' Plot S-Curve for a given LSH function
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

    stopifnot(n_bands > 0)
    stopifnot(band_width > 0)

    probs <- 1-(1-similarity^band_width)^n_bands

    plot(similarity, probs,
         xlab = "Jaccard Similarity of Two Strings",
         ylab = "Probability that Strings are Proposed as a Match",
         type="l",
         col = "blue"
    )
}

#' Find Probability of Match Based on Similarity
#'
#' @param n_bands: The number of LSH bands used in hashing
#'
#' @param band_width: The number of hashes in each band
#'
#' @return a decimal number giving the proability that the two items will be
#' returned as a candidate pair from the minihash algotithm.
#'
#' @export
lsh_probability <- function(similarity, n_bands, band_width){
    1-(1-similarity^band_width)^n_bands
}


