#' @export
lsh_anti_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "anti", by = by, threshold =  threshold)
}

#' @export
lsh_inner_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "inner", by = by, threshold =  threshold)
}

#' @export
lsh_left_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "left", by = by, threshold =  threshold)
}

#' @export
lsh_right_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "right", by = by, threshold =  threshold)
}

#' @export
lsh_full_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "full", by = by, threshold =  threshold)
}
