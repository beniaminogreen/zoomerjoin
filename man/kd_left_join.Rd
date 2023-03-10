% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kd_logical_joins.R
\name{kd_left_join}
\alias{kd_left_join}
\title{Spatial Left Join Using KD-Trees}
\usage{
kd_left_join(a, b, by = NULL, threshold = 1)
}
\arguments{
\item{a}{the first dataframe you wish to join.}

\item{b}{the second dataframe
you wish to join.}

\item{by}{a named vector indicating which columns to join on. Format should
be the same as dplyr: \code{by = c("column_name_in_df_a" = "column_name_in_df_b")}, but
two columns must be specified in each dataset (x column and y column).}

\item{threshold}{the distance threshold below which units should be considered a match}
}
\description{
Spatial Left Join Using KD-Trees
}
