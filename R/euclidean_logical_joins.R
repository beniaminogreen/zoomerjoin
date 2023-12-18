#' Spatial Anti Join Using LSH
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column). Specification
#' made with `dplyr::join_by()` are also accepted.
#'
#' @param n_bands the number of bands used in the LSH algorithm (default
#' is 30). Use this in conjunction with the \code{band_width} to determine the
#' performance of the hashing.
#'
#' @param band_width the length of each band used in the minihashing algorithm
#' (default is 5) Use this in conjunction with the \code{n_bands} to determine
#' the performance of the hashing.
#'
#' @param threshold the distance threshold below which units should be considered a match
#'
#' @param r the r hyperparameter used to govern the sensitivity of the locality sensitive hash, as described in
#'
#' @param progress set to `TRUE` to print progress
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
#' @references Datar, Mayur, Nicole Immorlica, Pitor Indyk, and Vahab Mirrokni.
#' "Locality-Sensitive Hashing Scheme Based on p-Stable Distributions" SCG '04:
#' Proceedings of the twentieth annual symposium on Computational geometry
#' (2004): 253-262
#'
#' @examples
#'n <- 10
#'
#'X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
#'X_2 <- X_1 + .0000001
#'
#'X_1 <- as.data.frame(X_1)
#'X_2 <- as.data.frame(X_2)
#'
#'X_1$id_1 <- 1:n
#'X_2$id_2 <- 1:n
#'
#'
#'euclidean_anti_join(X_1, X_2, by = c("V1", "V2"), threshold =.00005)
#'
#'
#' @export
euclidean_anti_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5,  r=.5, progress = FALSE) {
    euclidean_join_core(a, b, mode = "anti", by = by, threshold =  threshold, n_bands = n_bands, progress = progress, band_width = band_width, r = r)
}

#' Spatial Inner Join Using LSH
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe
#' you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column).
#'
#' @param n_bands the number of bands used in the LSH algorithm (default
#' is 30). Use this in conjunction with the \code{band_width} to determine the
#' performance of the hashing.
#'
#' @param band_width the length of each band used in the minihashing algorithm
#' (default is 5) Use this in conjunction with the \code{n_bands} to determine
#' the performance of the hashing.
#'
#' @param threshold the distance threshold below which units should be considered a match
#'
#' @param r the r hyperparameter used to govern the sensitivity of the locality sensitive hash, as described in
#'
#' @param progress set to `TRUE` to print progress
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
#' @references Datar, Mayur, Nicole Immorlica, Pitor Indyk, and Vahab Mirrokni.
#' "Locality-Sensitive Hashing Scheme Based on p-Stable Distributions" SCG '04:
#' Proceedings of the twentieth annual symposium on Computational geometry
#' (2004): 253-262
#'
#' @examples
#'n <- 10
#'
#'X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
#'X_2 <- X_1 + .0000001
#'
#'X_1 <- as.data.frame(X_1)
#'X_2 <- as.data.frame(X_2)
#'
#'X_1$id_1 <- 1:n
#'X_2$id_2 <- 1:n
#'
#'euclidean_inner_join(X_1, X_2, by = c("V1", "V2"), threshold =.00005)
#'
#'
#' @export
euclidean_inner_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r=.5, progress = FALSE) {
    euclidean_join_core(a, b, mode = "inner", by = by, threshold =  threshold, n_bands = n_bands,progress = progress,  band_width = band_width, r = r)
}

#' Spatial Left Join Using LSH
#'
#' @inheritParams euclidean_anti_join
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
#' @references Datar, Mayur, Nicole Immorlica, Pitor Indyk, and Vahab Mirrokni.
#' "Locality-Sensitive Hashing Scheme Based on p-Stable Distributions" SCG '04:
#' Proceedings of the twentieth annual symposium on Computational geometry
#' (2004): 253-262
#'
#' @examples
#'n <- 10
#'
#'X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
#'X_2 <- X_1 + .0000001
#'
#'X_1 <- as.data.frame(X_1)
#'X_2 <- as.data.frame(X_2)
#'
#'X_1$id_1 <- 1:n
#'X_2$id_2 <- 1:n
#'
#'euclidean_left_join(X_1, X_2, by = c("V1", "V2"), threshold =.00005)
#'
#'
#' @export
euclidean_left_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r=.5, progress = FALSE) {
    euclidean_join_core(a, b, mode = "left", by = by, threshold =  threshold, n_bands = n_bands,progress = progress,  band_width = band_width, r = r)
}

#' Spatial Right Join Using LSH
#'
#' @inheritParams euclidean_anti_join
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
#' @references Datar, Mayur, Nicole Immorlica, Pitor Indyk, and Vahab Mirrokni.
#' "Locality-Sensitive Hashing Scheme Based on p-Stable Distributions" SCG '04:
#' Proceedings of the twentieth annual symposium on Computational geometry
#' (2004): 253-262
#'
#' @examples
#'n <- 10
#'
#'X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
#'X_2 <- X_1 + .0000001
#'X_1 <- as.data.frame(X_1)
#'X_2 <- as.data.frame(X_2)
#'
#'X_1$id_1 <- 1:n
#'X_2$id_2 <- 1:n
#'
#'euclidean_right_join(X_1, X_2, by = c("V1", "V2"), threshold =.00005)
#'
#'
#' @export
euclidean_right_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r=.5, progress = FALSE) {
    euclidean_join_core(a, b, mode = "right", by = by, threshold =  threshold, n_bands = n_bands,progress = progress,  band_width = band_width, r = r)
}

#' Spatial Full Join Using LSH
#'
#' @inheritParams euclidean_anti_join
#'
#' @return a tibble fuzzily-joined on the basis of the variables in `by.` Tries
#' to adhere to the same standards as the dplyr-joins, and uses the same
#' logical joining patterns (i.e. inner-join joins and keeps only observations in both datasets).
#'
#' @references Datar, Mayur, Nicole Immorlica, Pitor Indyk, and Vahab Mirrokni.
#' "Locality-Sensitive Hashing Scheme Based on p-Stable Distributions" SCG '04:
#' Proceedings of the twentieth annual symposium on Computational geometry
#' (2004): 253-262
#'
#' @examples
#'n <- 10
#'
#'X_1 <- matrix(c(seq(0,1,1/(n-1)), seq(0,1,1/(n-1))), nrow=n)
#'X_2 <- X_1 + .0000001
#'
#'X_1 <- as.data.frame(X_1)
#'X_2 <- as.data.frame(X_2)
#'
#'X_1$id_1 <- 1:n
#'X_2$id_2 <- 1:n
#'
#'euclidean_full_join(X_1, X_2, by = c("V1", "V2"), threshold =.00005)
#'
#' @export
euclidean_full_join <- function(a, b, by = NULL, threshold = 1, n_bands = 30, band_width = 5, r=.5, progress = FALSE) {
    euclidean_join_core(a, b, mode = "full", by = by, threshold =  threshold, n_bands = n_bands, progress = progress, band_width = band_width, r = r)
}
