% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dental_plyr.R
\name{dental_join}
\alias{dental_join}
\title{Produce detailed tooth position information from tooth notation}
\usage{
dental_join(data, by = tooth, notation = c("FDI", "standards", "text"), ...)
}
\arguments{
\item{data}{A data frame containing a column with a unique identifier and
one column per tooth or tooth surface.}

\item{by}{string. name of column containing the tooth notation.}

\item{notation}{string. Which notation convention is used to name the columns
with dental scores. Options are "FDI", "standards", "text". See the
\code{tooth_notation} object for more details.}

\item{...}{supply additional arguments to \code{left_join()}}
}
\value{
Returns the original data frame along with detailed information about
the tooth including, region (maxilla, mandible),
position (anterior, posterior), side, class (incisor, canine, etc.), type,
(first incisor, second molar, etc.), and quadrant.
}
\description{
Produce detailed tooth position information from tooth notation
}
\examples{
mb11_caries \%>\%
  dental_longer(-id) \%>\%
  dental_join()

}
