#' Calculate a dental index or ratio
#'
#' Calculate a dental index, such as a calculus index, or ratio, such as caries
#' ratio.
#'
#' @details Function to calculate the index or ratio of dental diseases.
#' `dental_ratio()` is just a wrapper for `dental_index()`
#' where the output column 'index' is changed to 'count', and 'score_sum' to 'ratio'.
#' @param data long format data frame with tooth position information and either lesion counts or scores.
#' @param score Scores of a dental lesion (e.g. caries counts or dental calculus score).
#' @param count Counts of a dental lesion (e.g. caries counts or dental calculus score).
#' @return Returns a data frame containing the grouping variable(s), the number of
#' teeth per group, the lesion count or sum of scores, and the calculated index
#' or ratio.
#' @examples
#' library(dplyr)
#' library(tidyr)
#' # dental calculus index
#' mb11_calculus %>%
#'   dental_longer(-id, rm_char = "t", names_sep = "_") %>%
#'   group_by(class) %>% # calculate index per tooth class
#'   dental_index()
#'
#' @name dental-indices
NULL

#' @describeIn dental-indices calculate dental disease index
#' @export
dental_index <- function(data, score = score){

  if(dplyr::is.grouped_df(data)){
    prev_groups <- paste(dplyr::groups(data), collapse = ",")
    message(sprintf("previously defined groups (%s) were used. If that was not expected, use `ungroup()` on the data frame before using the function.", prev_groups))
  }
  out_n <- dplyr::summarise(
    data,
    n = sum(!is.na( {{ score }} )),
    score_sum = sum({{ score }}, na.rm = T),
    .groups = "keep"
  )
  # detect if any groups have 0 observations
  if(sum(out_n$n == 0) != 0){
    out_n_old <- out_n
    # remove rows with no teeth to avoid dividing by 0
    out_n <- out_n %>%
      dplyr::filter(n > 0)
    rows_removed <- nrow(out_n_old) - nrow(out_n)
    warning(paste(rows_removed, "rows removed because of no teeth present in groupings."))
  }
  out <- dplyr::mutate(out_n, index = score_sum / n) %>%
    dplyr::ungroup()
  out
}

#' @describeIn dental-indices calculate dental disease ratio
#' @export
dental_ratio <- function(data, count = count){
  data %>%
    dental_index(score = {{ count }}) %>%
    dplyr::rename(
      ratio = index,
      count = score_sum
    )
}
