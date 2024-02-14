#' Fuzzy joins for Euclidean distance using Locality Sensitive Hashing
#'
#' @inheritParams jaccard_left_join
#' @param threshold The distance threshold below which units should be
#'   considered a match. Note that contrary to Jaccard joins, this value is
#'   about the distance and not the similarity. Therefore, a lower value means a
#'   higher similarity.
#' @param r Hyperparameter used to govern the sensitivity of the locality
#'   sensitive hash. Corresponds to the width of the hash bucket in the LSH
#'   algorithm. Increasing values of `r` mean more hash collisions and higher
#'   sensitivity (fewer false-negatives) at the cost of lower specificity (more
#'   false-positives and longer run time). For more information, see the
#'   description in \doi{10.1145/997817.997857}.
#'
#' @return A tibble fuzzily-joined on the basis of the variables in `by.` Tries
#'   to adhere to the same standards as the dplyr-joins, and uses the same
#'   logical joining patterns (i.e. inner-join joins and keeps only observations
#'   in both datasets).
#'
#' @references Datar, Mayur, Nicole Immorlica, Pitor Indyk, and Vahab Mirrokni.
#'   "Locality-Sensitive Hashing Scheme Based on p-Stable Distributions" SCG
#'   '04: Proceedings of the twentieth annual symposium on Computational
#'   geometry (2004): 253-262
#'
#' @export
#' @rdname euclidean-joins
#'
#' @examples
#' n <- 10
#'
#' # Build two matrices that have close values
#' X_1 <- matrix(c(seq(0, 1, 1 / (n - 1)), seq(0, 1, 1 / (n - 1))), nrow = n)
#' X_2 <- X_1 + .0000001
#'
#' X_1 <- as.data.frame(X_1)
#' X_2 <- as.data.frame(X_2)
#'
#' X_1$id_1 <- 1:n
#' X_2$id_2 <- 1:n
#'
#' # only keep observations that have a match
#' euclidean_inner_join(X_1, X_2, by = c("V1", "V2"), threshold = .00005)
#'
#' # keep all observations from X_1, regardless of whether they have a match
#' euclidean_inner_join(X_1, X_2, by = c("V1", "V2"), threshold = .00005)
euclidean_anti_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r = .5, progress = FALSE) {
  euclidean_join_core(a, b, mode = "anti", by = by, threshold = threshold, n_bands = n_bands, progress = progress, band_width = band_width, r = r)
}

#' @rdname euclidean-joins
#' @export
euclidean_inner_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r = .5, progress = FALSE) {
  euclidean_join_core(a, b, mode = "inner", by = by, threshold = threshold, n_bands = n_bands, progress = progress, band_width = band_width, r = r)
}

#' @rdname euclidean-joins
#' @export
euclidean_left_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r = .5, progress = FALSE) {
  euclidean_join_core(a, b, mode = "left", by = by, threshold = threshold, n_bands = n_bands, progress = progress, band_width = band_width, r = r)
}

#' @rdname euclidean-joins
#' @export
euclidean_right_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r = .5, progress = FALSE) {
  euclidean_join_core(a, b, mode = "right", by = by, threshold = threshold, n_bands = n_bands, progress = progress, band_width = band_width, r = r)
}

#' @rdname euclidean-joins
#' @export
euclidean_full_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r = .5, progress = FALSE) {
  euclidean_join_core(a, b, mode = "full", by = by, threshold = threshold, n_bands = n_bands, progress = progress, band_width = band_width, r = r)
}
