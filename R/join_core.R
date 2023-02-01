lsh_join <- function (a, b, mode, by, n_gram_width, n_bands, band_width, threshold) {

    stopifnot("'threshold' must be between 0 and 1" = threshold <= 1 & threshold>=0)
    stopifnot("'n_bands' must be greater than 0" = n_bands > 0)
    stopifnot("'band_width' must be greater than 0" = band_width > 0)
    stopifnot("'n_gram_width' must be greater than 0" = n_gram_width > 0)


    if (is.null(by)) {
        by_a <- intersect(names(a), names(b))
        by_b <- intersect(names(a), names(b))
        stopifnot("Can't Determine Column to Match on" = length(by_a)==1)
        message(paste0("Joining by '", by_a, "'\n"))
    } else {
        stopifnot("by must have length 1" = length(by)==1)

        if (!is.null(names(by))) {
            by_a <- names(by)
            by_b <- by
        } else {
            by_a <- by
            by_b <- by
        }

        stopifnot(by_a %in% names(a))
        stopifnot(by_b %in% names(b))
    }

    match_table <- rust_lsh_join(
             dplyr::pull(a,by_a), dplyr::pull(b,by_b),
             n_gram_width, n_bands, band_width, threshold)

    names_in_both <- intersect(names(a), names(b))

    names(a)[names(a) %in% names_in_both] <- paste0(names(a)[names(a) %in% names_in_both], ".x")
    names(b)[names(b) %in% names_in_both] <- paste0(names(b)[names(b) %in% names_in_both], ".y")

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
