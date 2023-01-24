
#' @export
lsh_join <- function (a, b, mode, match_col, n_gram_width, n_bands, band_width, threshold) {

    stopifnot("'threshold' must be between 0 and 1" = threshold <= 1 & threshold>=0)
    stopifnot("'n_bands' must be greater than 0" = n_bands > 0)
    stopifnot("'band_width' must be greater than 0" = n_bands > 0)
    stopifnot("'n_gram_width' must be greater than 0" = n_gram_width > 0)


    if (is.null(match_col)) {
        match_col_a <- intersect(names(a), names(b))
        match_col_b <- intersect(names(a), names(b))
        stopifnot("Can't Determine Column to Match on" = length(match_col_a)==1)
        cat(paste0("Joining by '", match_col_a, "'\n"))
    } else {
        stopifnot("Match_col improperly specified" = length(match_col)==1)
        match_col_a <- names(match_col)
        match_col_b <- match_col
    }

    match_table <- rust_lsh_join(
             dplyr::pull(a,match_col_a), dplyr::pull(b,match_col_b),
             n_gram_width, n_bands, band_width, threshold)

    names(a)[names(a) == match_col_a] <- paste0(match_col_a, ".x")
    names(b)[names(b) == match_col_b] <- paste0(match_col_b, ".y")

    matches <- dplyr::bind_cols(a[match_table[, 1], ], b[match_table[, 2], ])
    not_matched_a <- ! 1:nrow(a) %in% match_table[,1]
    not_matched_b <- ! 1:nrow(b) %in% match_table[,2]

    if (mode == "left") {
        matches <- dplyr::bind_rows(matches,a[not_matched_a,])
    } else if (mode == "right") {
        matches <- dplyr::bind_rows(matches,b[not_matched_b,])
    } else if (mode == "full") {
        matches <- dplyr::bind_rows(matches,a[not_matched_a,],b[not_matched_b,])
    } else if (mode == "inner"){
        matches <- matches
    } else if (mode == "anti") {
        matches <- dplyr::bind_rows(a[not_matched_a,], b[not_matched_b,])
    } else {
        stop("Invalid Mode Selected!")
    }
}

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
