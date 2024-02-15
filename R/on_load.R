# nocov start
.onAttach <- function(libname, pkgname) {
  if (Sys.getenv("_R_CHECK_LIMIT_CORES_") != "") {
    if (as.logical(Sys.getenv("_R_CHECK_LIMIT_CORES_"))) {
      packageStartupMessage("_R_CHECK_LIMIT_CORES_ is set to TRUE. Running on 2 cores")
      Sys.setenv("RAYON_NUM_THREADS" = 2)
    }
  }
}
# nocov end