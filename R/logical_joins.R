#' Fuzzy inner-join using MiniHashing
#'
#' @param a the first dataframe you wish to join
#' @param b the second dataframe you wish to join
#' @param match_col a named vector indicating which columns to join on
#' @param n_gram_width the length of the n_grams used in calculating the jaccard similarity
#' @param n_bands the number of bands used in the minihash algorithm (default is 40)
#' @param band_width the length of each band used in the minihashing algorithm (default is 5)
#' @param n_bands a named vector indicating which columns to join on
#'
#' @export
lsh_inner_join <- function(a, b,
                            match_col = NULL,
                            n_gram_width = 2,
                            n_bands = 40,
                            band_width = 5,
                            threshold = .95) {
    lsh_join(a, b, mode = "inner", match_col = match_col,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy anti-join using MiniHashing
#'
#' @param a the first dataframe you wish to join
#' @param b the second dataframe you wish to join
#' @param match_col a named vector indicating which columns to join on
#' @param n_gram_width the length of the n_grams used in calculating the jaccard similarity
#' @param n_bands the number of bands used in the minihash algorithm (default is 40)
#' @param band_width the length of each band used in the minihashing algorithm (default is 5)
#' @param n_bands a named vector indicating which columns to join on
#'
#' @export
lsh_anti_join <- function(a, b,
                            match_col = NULL,
                            n_gram_width = 2,
                            n_bands = 40,
                            band_width = 5,
                            threshold = .95) {
    lsh_join(a, b, mode = "anti", match_col = match_col,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy left-join using MiniHashing
#'
#' @param a the first dataframe you wish to join
#' @param b the second dataframe you wish to join
#' @param match_col a named vector indicating which columns to join on
#' @param n_gram_width the length of the n_grams used in calculating the jaccard similarity
#' @param n_bands the number of bands used in the minihash algorithm (default is 40)
#' @param band_width the length of each band used in the minihashing algorithm (default is 5)
#' @param n_bands a named vector indicating which columns to join on
#'
#' @export
lsh_left_join <- function(a, b,
                            match_col = NULL,
                            n_gram_width = 2,
                            n_bands = 40,
                            band_width = 5,
                            threshold = .95) {
    lsh_join(a, b, mode = "left", match_col = match_col,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy right-join using MiniHashing
#'
#' @param a the first dataframe you wish to join
#' @param b the second dataframe you wish to join
#' @param match_col a named vector indicating which columns to join on
#' @param n_gram_width the length of the n_grams used in calculating the jaccard similarity
#' @param n_bands the number of bands used in the minihash algorithm (default is 40)
#' @param band_width the length of each band used in the minihashing algorithm (default is 5)
#' @param n_bands a named vector indicating which columns to join on
#'
#' @export
lsh_right_join <- function(a, b,
                            match_col = NULL,
                            n_gram_width = 2,
                            n_bands = 40,
                            band_width = 5,
                            threshold = .95) {
    lsh_join(a, b, mode = "right", match_col = match_col,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}

#' Fuzzy full-join using MiniHashing
#'
#' @param a the first dataframe you wish to join
#' @param b the second dataframe you wish to join
#' @param match_col a named vector indicating which columns to join on
#' @param n_gram_width the length of the n_grams used in calculating the jaccard similarity
#' @param n_bands the number of bands used in the minihash algorithm (default is 40)
#' @param band_width the length of each band used in the minihashing algorithm (default is 5)
#' @param n_bands a named vector indicating which columns to join on
#'
#' @export
lsh_full_join <- function(a, b,
                            match_col = NULL,
                            n_gram_width = 2,
                            n_bands = 40,
                            band_width = 5,
                            threshold = .95) {
    lsh_join(a, b, mode = "full", match_col = match_col,
                   n_gram_width = n_gram_width,
                   n_bands = n_bands, band_width = band_width,
                   threshold =  threshold)
}
