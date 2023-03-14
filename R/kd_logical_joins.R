#' Spatial Anti Join Using KD-Trees
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe
#' you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column).
#'
#' @param threshold the distance threshold below which units should be considered a match
#'
#'
#'
#' @export
kd_anti_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "anti", by = by, threshold =  threshold)
}

#' Spatial Inner Join Using KD-Trees
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe
#' you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column).
#'
#' @param threshold the distance threshold below which units should be considered a match
#'
#' @export
kd_inner_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "inner", by = by, threshold =  threshold)
}

#' Spatial Left Join Using KD-Trees
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe
#' you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column).
#'
#' @param threshold the distance threshold below which units should be considered a match
#'
#' @export
kd_left_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "left", by = by, threshold =  threshold)
}

#' Spatial Right Join Using KD-Trees
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe
#' you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column).
#'
#' @param threshold the distance threshold below which units should be considered a match
#'
#' @export
kd_right_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "right", by = by, threshold =  threshold)
}

#' Spatial Full Join Using KD-Trees
#'
#' @param a the first dataframe you wish to join.
#' @param b the second dataframe
#' you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
#' two columns must be specified in each dataset (x column and y column).
#'
#' @param threshold the distance threshold below which units should be considered a match
#'
#' @export
kd_full_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "full", by = by, threshold =  threshold)
}
