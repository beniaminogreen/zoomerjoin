#' @export
kd_anti_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "anti", by = by, threshold =  threshold)
}

#' @export
kd_inner_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "inner", by = by, threshold =  threshold)
}

#' @export
kd_left_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "left", by = by, threshold =  threshold)
}

#' @export
kd_right_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "right", by = by, threshold =  threshold)
}

#' @export
kd_full_join <- function(a, b, by = NULL, threshold = 1) {
    kd_join_core(a, b, mode = "full", by = by, threshold =  threshold)
}
