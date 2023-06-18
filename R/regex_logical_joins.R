#' Regex inner-join
#'
#' @param a the first dataframe you wish to join.
#'
#' @param b the second dataframe you wish to join.
#'
#' @param regex the regular expression you wish to join on
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
regex_inner_join <- function(a, b, regex,  by = NULL) {
    regex_join_core(a,b,regex, mode = "inner", by = by)
}

#' Regex left-join
#'
#' @param a the first dataframe you wish to join.
#'
#' @param b the second dataframe you wish to join.
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
regex_left_join <- function(a, b, regex,  by = NULL) {
    regex_join_core(a,b,regex, mode = "left", by = by)
}

#' Regex right-join
#'
#' @param a the first dataframe you wish to join.
#'
#' @param b the second dataframe you wish to join.
#'
#' @param regex the regular expression you wish to join on
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
regex_right_join <- function(a, b, regex,  by = NULL) {
    regex_join_core(a,b,regex, mode = "right", by = by)
}

#' Regex anti-join
#'
#' @param a the first dataframe you wish to join.
#'
#' @param b the second dataframe you wish to join.
#'
#' @param regex the regular expression you wish to join on
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
regex_anti_join <- function(a, b, regex,  by = NULL) {
    regex_join_core(a,b,regex, mode = "anti", by = by)
}

#' Regex full-join
#'
#' @param a the first dataframe you wish to join.
#'
#' @param b the second dataframe you wish to join.
#'
#' @param regex the regular expression you wish to join on
#'
#' @param by a named vector indicating which columns to join on. Format should
#' be the same as dplyr: \code{by = c("column_name_in_df_a" =
#' "column_name_in_df_b")}
#'
regex_full_join <- function(a, b, regex,  by = NULL) {
    regex_join_core(a,b,regex, mode = "full", by = by)
}
