lsh_join <- function (a, b, mode, match_col, n_gram_width, n_bands, band_width, threshold) {

    stopifnot("'threshold' must be between 0 and 1" = threshold <= 1 & threshold>=0)
    stopifnot("'n_bands' must be greater than 0" = n_bands > 0)
    stopifnot("'band_width' must be greater than 0" = band_width > 0)
    stopifnot("'n_gram_width' must be greater than 0" = n_gram_width > 0)


    if (is.null(match_col)) {
        match_col_a <- intersect(names(a), names(b))
        match_col_b <- intersect(names(a), names(b))
        stopifnot("Can't Determine Column to Match on" = length(match_col_a)==1)
        message(paste0("Joining by '", match_col_a, "'\n"))
    } else {
        stopifnot("match_col must have length 1" = length(match_col)==1)

        match_col_a <- names(match_col)
        match_col_b <- match_col

        stopifnot(match_col_a %in% names(a))
        stopifnot(match_col_b %in% names(b))
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
