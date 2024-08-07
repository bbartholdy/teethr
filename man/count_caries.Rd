% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/caries.R
\name{count_caries}
\alias{count_caries}
\title{Convert caries scores to lesion counts}
\usage{
count_caries(
  data,
  caries = score,
  no_lesion = NULL,
  lesion_sep = NULL,
  unobs = NA,
  method = c("location", "standards", "count")
)
}
\arguments{
\item{data}{data frame containing caries scores}

\item{caries}{column containing caries scores}

\item{no_lesion}{value used to indicate no caries lesions}

\item{lesion_sep}{string. character used to separate multiple lesions.}

\item{unobs}{value used to indicate unobservable}

\item{method}{string. what method was used to score caries lesions.}
}
\description{
Convert caries scores to lesion counts
}
