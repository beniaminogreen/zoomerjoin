#' Fuzzy inner-join using Locality Sensitive Hashing
#'
#' Find similar rows between two tables using the hamming distance. The hamming
#' distance is equal to the number characters two strings differ by, or is
#' equal to infinity if two strings are of different lengths
#'
#'
#' @param a the first dataframe you wish to join.
#'
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column). Specification
#' made with `dplyr::join_by()` are also accepted.
#'
#' @param n_bands the number of bands used in the locality sensitive hashing
#' algorithm (default is 100). Use this in conjunction with the
#' \code{band_width} to determine the performance of the hashing. Generally
#' speaking, a higher number of bands leads to greater recall at the cost of
#' higher runtime.
#'
#' @param band_width the length of each band used in the minihashing algorithm
#' (default is 8) Use this in conjunction with the \code{n_bands} to determine
#' the performance of the hashing. Generally speaking a wider number of bands
#' decreases the number of false positives, decreasing runtime at the cost of
#' lower sensitivity (true matches are less likely to be found).
#'
#' @param clean should the strings that you fuzzy join on be cleaned (coerced
#' to lower-case, stripped of punctuation and spaces)? Default is FALSE
#'
#' @param progress set to `TRUE` to print progress
#'
#' @param similarity_column an optional character vector. If provided, the data
#' frame will contain a column with this name giving the jaccard similarity
#' between the two fields. Extra column will not be present if anti-joining.
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
#' @rdname hamming-joins
#' @export
#' @examples
#' # load baby names data
#' # install.packages("babynames")
#' library(babynames)
#'
#' baby_names <- data.frame(name = tolower(unique(babynames$name))[1:500])
#' baby_names_mispelled <- data.frame(
#'   name_mispelled = gsub("[aeiouy]", "x", baby_names$name)
#' )
#'
#' # Run the join and only keep rows that have a match:
#' hamming_inner_join(
#'   baby_names,
#'   baby_names_mispelled,
#'   by = c("name" = "name_mispelled"),
#'   threshold = 4,
#'   n_bands = 100,
#'   band_width = 10,
#'   clean = FALSE # default
#' )
#'
#' # Run the join and keep all rows from the first dataset, regardless of whether
#' # they have a match:
#' jaccard_left_join(
#'   baby_names,
#'   baby_names_mispelled,
#'   by = c("name" = "name_mispelled"),
#'   threshold = 4,
#'   n_bands = 100,
#'   band_width = 10,
#' )
hamming_inner_join <- function(a, b,
                           by = NULL,
                           n_bands = 100,
                           band_width = 100,
                           threshold = 2,
                           progress = FALSE,
                           clean = FALSE,
                           similarity_column=NULL) {
    hamming_join(a, b, mode = "inner",
                 by = by,
                 n_bands = n_bands,
                 band_width = band_width,
                 threshold =  threshold,
                 progress = progress,
                 similarity_column =  similarity_column,
                 clean=clean)
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
                           similarity_column=NULL) {
    hamming_join(a, b, mode = "anti",
                 by = by,
                 n_bands = n_bands,
                 band_width = band_width,
                 threshold =  threshold,
                 progress = progress,
                 similarity_column =  similarity_column,
                 clean=clean)
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
                           similarity_column=NULL) {
    hamming_join(a, b, mode = "left",
                 by = by,
                 n_bands = n_bands,
                 band_width = band_width,
                 threshold =  threshold,
                 progress = progress,
                 similarity_column =  similarity_column,
                 clean=clean)
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
                           similarity_column=NULL) {
    hamming_join(a, b, mode = "right",
                 by = by,
                 n_bands = n_bands,
                 band_width = band_width,
                 threshold =  threshold,
                 progress = progress,
                 similarity_column =  similarity_column,
                 clean=clean)
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
                           similarity_column=NULL) {
    hamming_join(a, b, mode = "full",
                 by = by,
                 n_bands = n_bands,
                 band_width = band_width,
                 threshold =  threshold,
                 progress = progress,
                 similarity_column =  similarity_column,
                 clean=clean)
}
