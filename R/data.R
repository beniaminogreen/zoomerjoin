#' Donors from DIME Database
#'
#' A set of donor names from the Database on Ideology, Money in Politics, and
#' Elections (DIME).  This dataset was used as a benchmark in the 2021 APSR
#' paper Adaptive Fuzzy String Matching: How to Merge Datasets with Only One
#' (Messy) Identifying Field by Aaron R. Kaufman and Aja Klevs, the dataset in
#' this package is a subset of the data from the replication archive of that
#' paper. The full dataset can be found in the paper's replication materials
#' here: \doi{10.7910/DVN/4031UL}.
#'
#' @author Adam Bonica
#' @references \doi{10.7910/DVN/4031UL}
#' @name dime_data
#' @docType data
#' @format ## `dime_data`
#' A data frame with 10,000 rows and 2 columns:
#' \describe{
#'   \item{id}{Numeric ID / Row Number}
#'   \item{x}{Donor Name}
#'   ...
#' }#' @source <https://www.who.int/teams/global-tuberculosis-programme/data>
"dime_data"
