#' Fuzzy inner-join using MiniHashing
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format
#' should be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
#' @param n_gram_width the length of the n_grams used in calculating the
#' jaccard similarity. For best performance, I set this large enough that the
#' chance any string has a specific n_gram is low (i.e. \code{n_gram_width} = 2
#' or 3 when matching on first names, 5 or 6 when matching on entire
#' sentences).
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
#' @export
lsh_inner_join <- function(a, b,
                            by = NULL,
                            n_gram_width = 2,
                            n_bands = 45,
                            band_width = 8,
                            threshold = .95) {
    lsh_join(a, b, mode = "inner", by = by,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy anti-join using MiniHashing
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format
#' should be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
#' @param n_gram_width the length of the n_grams used in calculating the
#' jaccard similarity. For best performance, I set this large enough that the
#' chance any string has a specific n_gram is low (i.e. \code{n_gram_width} = 2
#' or 3 when matching on first names, 5 or 6 when matching on entire
#' sentences).
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
#' @export
lsh_anti_join <- function(a, b,
                            by = NULL,
                            n_gram_width = 2,
                            n_bands = 45,
                            band_width = 8,
                            threshold = .95) {
    lsh_join(a, b, mode = "anti", by = by,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy left-join using MiniHashing
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format
#' should be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
#' @param n_gram_width the length of the n_grams used in calculating the
#' jaccard similarity. For best performance, I set this large enough that the
#' chance any string has a specific n_gram is low (i.e. \code{n_gram_width} = 2
#' or 3 when matching on first names, 5 or 6 when matching on entire
#' sentences).
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
#' @export
lsh_left_join <- function(a, b,
                            by = NULL,
                            n_gram_width = 2,
                            n_bands = 45,
                            band_width = 8,
                            threshold = .95) {
    lsh_join(a, b, mode = "left", by = by,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy right-join using MiniHashing
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format
#' should be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
#' @param n_gram_width the length of the n_grams used in calculating the
#' jaccard similarity. For best performance, I set this large enough that the
#' chance any string has a specific n_gram is low (i.e. \code{n_gram_width} = 2
#' or 3 when matching on first names, 5 or 6 when matching on entire
#' sentences).
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
#' @export
lsh_right_join <- function(a, b,
                            by = NULL,
                            n_gram_width = 2,
                            n_bands = 45,
                            band_width = 8,
                            threshold = .95) {
    lsh_join(a, b, mode = "right", by = by,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy full-join using MiniHashing
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format
#' should be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
#' @param n_gram_width the length of the n_grams used in calculating the
#' jaccard similarity. For best performance, I set this large enough that the
#' chance any string has a specific n_gram is low (i.e. \code{n_gram_width} = 2
#' or 3 when matching on first names, 5 or 6 when matching on entire
#' sentences).
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
#' @export
lsh_full_join <- function(a, b,
                            by = NULL,
                            n_gram_width = 2,
                            n_bands = 45,
                            band_width = 8,
                            threshold = .95) {
    lsh_join(a, b, mode = "full", by = by,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}
