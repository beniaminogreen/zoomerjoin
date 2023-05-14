multi_by_validate <- function(a,b, by) {
    if (is.null(by)) {
        by_a <- intersect(names(a), names(b))
        by_b <- intersect(names(a), names(b))
    } else {
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
    return(list(
                by_a,
                by_b
                ))
}

euclidean_join_core <- function (a, b, by = NULL, n_bands = 30, band_width = 10, threshold=1.0, r=.5, mode="inner") {

    stopifnot("'radius' must be greater than 0" = threshold > 0)

    by <- multi_by_validate(a,b,by)
    by_a <- by[[1]]
    by_b <- by[[2]]
    stopifnot("There should be no NA's in by_a[1]"=!any(is.na(dplyr::pull(a,by_a[1]))))
    stopifnot("There should be no NA's in by_a[2]"=!any(is.na(dplyr::pull(a,by_a[2]))))
    stopifnot("There should be no NA's in by_b[1]"=!any(is.na(dplyr::pull(b,by_b[1]))))
    stopifnot("There should be no NA's in by_b[2]"=!any(is.na(dplyr::pull(b,by_b[2]))))

    match_table <- rust_p_norm_join(
                                as.matrix(dplyr::select(a, dplyr::all_of(by_a))),
                                as.matrix(dplyr::select(b, dplyr::all_of(by_b))),
                                threshold,
                                n_bands, band_width, r)

    names_in_both <- intersect(names(a), names(b))

    names(a)[names(a) %in% names_in_both] <-
        paste0(names(a)[names(a) %in% names_in_both], ".x")
    names(b)[names(b) %in% names_in_both] <-
        paste0(names(b)[names(b) %in% names_in_both], ".y")

    matches <- dplyr::bind_cols(a[match_table[, 1], ], b[match_table[, 2], ])
    not_matched_a <- ! seq(nrow(a)) %in% match_table[,1]
    not_matched_b <- ! seq(nrow(b)) %in% match_table[,2]

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
    return(matches)
}
