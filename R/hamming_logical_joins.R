#' Fuzzy inner-join using minihashing
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
#' @param n_bands the number of bands used in the minihash algorithm (default
#' is 40). Use this in conjunction with the \code{band_width} to determine the
#' performance of the hashing. The default settings are for a
#' (.2,.8,.001,.999)-sensitive hash i.e. that pairs with a similarity of less
#' than .2 have a >.1% chance of being compared, while pairs with a similarity
#' of greater than .8 have a >99.9% chance of being compared.
#'
#' @param band_width the length of each band used in the minihashing algorithm
#' (default is 8) Use this in conjunction with the \code{n_bands} to determine
#' the performance of the hashing. The default settings are for a
#' (.2,.8,.001,.999)-sensitive hash i.e. that pairs with a similarity of less
#' than .2 have a >.1% chance of being compared, while pairs with a similarity
#' of greater than .8 have a >99.9% chance of being compared.
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
#' @export
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

#' Fuzzy anti-join using minihashing
#'
#' @inheritParams hamming_inner_join
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
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

#' Fuzzy left-join using minihashing
#'
#' @inheritParams hamming_inner_join
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
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

#' Fuzzy left-join using minihashing
#'
#' @inheritParams hamming_inner_join
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
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


#' Fuzzy full-join using minihashing
#'
#' @inheritParams hamming_inner_join
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
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
