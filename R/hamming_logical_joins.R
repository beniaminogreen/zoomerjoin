#' Fuzzy joins for Hamming distance using Locality Sensitive Hashing
#'
#' Find similar rows between two tables using the hamming distance. The hamming
#' distance is equal to the number characters two strings differ by, or is equal
#' to infinity if two strings are of different lengths
#'
#' @inheritParams jaccard_left_join
#'
#' @param n_bands The number of bands used in the locality sensitive hashing
#'   algorithm (default is 100). Use this in conjunction with the
#'   \code{band_width} to determine the performance of the hashing. Generally
#'   speaking, a higher number of bands leads to greater recall at the cost of
#'   higher runtime.
#'
#' @param band_width The length of each band used in the minihashing algorithm
#'   (default is 8). Use this in conjunction with the \code{n_bands} to
#'   determine the performance of the hashing. Generally speaking a wider number
#'   of bands decreases the number of false positives, decreasing runtime at the
#'   cost of lower sensitivity (true matches are less likely to be found).
#'
#' @param threshold The Hamming distance threshold below which two strings
#'   should be considered a match. A distance of zero corresponds to complete
#'   equality between strings, while a distance of 'x' between two strings means
#'   that 'x' substitutions must be made to transform one string into the other.
#'
#' @param similarity_column An optional character vector. If provided, the data
#'   frame will contain a column with this name giving the Hamming distance
#'   between the two fields. Extra column will not be present if anti-joining.
#' 
#' @param nthread Maximum number of threads to use. If `NULL` (default),
#'   Rayon's global thread pool is used, which typically uses all logical
#'   CPU cores available.
#'
#' @return A tibble fuzzily-joined on the basis of the variables in `by.` Tries
#'   to adhere to the same standards as the dplyr-joins, and uses the same
#'   logical joining patterns (i.e. inner-join joins and keeps only observations
#'   in both datasets).
#'
#' @rdname hamming-joins
#' @export
#' @examples
#' if (requireNamespace("babynames", quietly = TRUE)) {
#'   baby_names <- data.frame(
#'     name = tolower(unique(babynames::babynames$name))[1:500]
#'   )
#'
#'   baby_names_mispelled <- data.frame(
#'     name_mispelled = gsub("[aeiouy]", "x", baby_names$name)
#'   )
#'
#'   hamming_inner_join(
#'     baby_names,
#'     baby_names_mispelled,
#'     by = c("name" = "name_mispelled"),
#'     threshold = 3,
#'     n_bands = 150,
#'     band_width = 10,
#'     clean = FALSE
#'   )
#'
#'   hamming_left_join(
#'     baby_names,
#'     baby_names_mispelled,
#'     by = c("name" = "name_mispelled"),
#'     threshold = 3,
#'     n_bands = 150,
#'     band_width = 10
#'   )
#' }
hamming_inner_join <- function(a, b,
                               by = NULL,
                               n_bands = 100,
                               band_width = 8,
                               threshold = 2,
                               progress = FALSE,
                               clean = FALSE,
                               similarity_column = NULL,
                               nthread = NULL) {

  fuzzy_join_core(a = a, b = b, by = by,
            join_func = hamming_join,
            mode = "inner",
            n_bands = n_bands,
            band_width = band_width,
            threshold = threshold,
            progress = progress,
            similarity_column = similarity_column,
            clean = clean,
            nthread = nthread
  )

}

#' @rdname hamming-joins
#' @export
hamming_anti_join <- function(a, b,
                              by = NULL,
                              n_bands = 100,
                              band_width = 100,
                              threshold = 2,
                              progress = FALSE,
                              clean = FALSE,
                              similarity_column = NULL,
                              nthread = NULL) {

  fuzzy_join_core(a = a, b = b, by = by,
            join_func = hamming_join,
            mode = "anti",
            n_bands = n_bands,
            band_width = band_width,
            threshold = threshold,
            progress = progress,
            similarity_column = similarity_column,
            clean = clean,
            nthread = nthread
  )
}

#' @rdname hamming-joins
#' @export
hamming_left_join <- function(a, b,
                              by = NULL,
                              n_bands = 100,
                              band_width = 100,
                              threshold = 2,
                              progress = FALSE,
                              clean = FALSE,
                              similarity_column = NULL,
                              nthread = NULL) {

  fuzzy_join_core(a = a, b = b, by = by,
            join_func = hamming_join,
            mode = "left",
            n_bands = n_bands,
            band_width = band_width,
            threshold = threshold,
            progress = progress,
            similarity_column = similarity_column,
            clean = clean,
            nthread = nthread
  )
}

#' @rdname hamming-joins
#' @export
hamming_right_join <- function(a, b,
                               by = NULL,
                               n_bands = 100,
                               band_width = 100,
                               threshold = 2,
                               progress = FALSE,
                               clean = FALSE,
                               similarity_column = NULL,
                               nthread = NULL) {

  fuzzy_join_core(a = a, b = b, by = by,
            join_func = hamming_join,
            mode = "right",
            n_bands = n_bands,
            band_width = band_width,
            threshold = threshold,
            progress = progress,
            similarity_column = similarity_column,
            clean = clean,
            nthread = nthread
  )
}


#' @rdname hamming-joins
#' @export
hamming_full_join <- function(a, b,
                              by = NULL,
                              n_bands = 100,
                              band_width = 100,
                              threshold = 2,
                              progress = FALSE,
                              clean = FALSE,
                              similarity_column = NULL,
                              nthread = NULL) {
  fuzzy_join_core(a = a, b = b, by = by,
            join_func = hamming_join,
            mode = "full",
            n_bands = n_bands,
            band_width = band_width,
            threshold = threshold,
            progress = progress,
            similarity_column = similarity_column,
            clean = clean,
            nthread = nthread
  )
}
