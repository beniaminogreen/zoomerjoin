regex_join_core <- function(a, b, regex, mode, by) {
    a <- tibble::as_tibble(a)
    b <- tibble::as_tibble(b)


    by <- simple_by_validate(a,b,by)
    by_a <- by[[1]]
    by_b <- by[[2]]

    stopifnot("'by' vectors must have length 1" = length(by_a)==1)
    stopifnot("'by' vectors must have length 1" = length(by_b)==1)

    stopifnot("There should be no NA's in by_a"=!any(is.na(dplyr::pull(a,by_a))))
    stopifnot("There should be no NA's in by_b"=!any(is.na(dplyr::pull(b,by_b))))

    a_col <- dplyr::pull(a,by_a)
    b_col <- dplyr::pull(b,by_b)

    print(a_col)
    print(b_col)

    match_table <- rust_regex_join(a_col, b_col, regex)

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
