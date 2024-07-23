#' Convert a data frame containing dental scores to long format and add tooth
#' position variables.
#'
#' This function is a wrapper for `pivot_longer()` that converts a wide format
#' data frame to a long format with tooth names in a `tooth` column
#' (and `surface`, if applicable) and the score in a `score` column. It also
#' attaches additional columns with information about the type of tooth and the
#' position of the tooth in the mouth (type, class, region, etc.).
#'
#' @details
#' If there are multiple columns per tooth, i.e., if teeth were scored per surface
#' and variables are named something like <tooth number>_<surface name>,
#' `names_sep = "_"` (or whatever character was used to separate tooth number from
#' tooth surface) should be passed to pivot_longer via `...`. If no such
#' separator was used, use instead `names_pattern = <regex>`. See
#' \code{\link[tidyr]{pivot_longer}} for more details.
#'
#' @param data A data frame containing a column with a unique identifier and
#' one column per tooth or tooth surface.
#' @param cols Which columns to pivot into longer format. These should be the columns
#' containing the scores for each tooth/surface.
#' @param ... additional arguments passed on to \code{\link[tidyr]{pivot_longer}}.
#' @return Returns a longer data frame with one row per tooth or tooth surface,
#' with columns for tooth number, region (maxilla, mandible),
#' position (anterior, posterior), side, class (incisor, canine, etc.), type, and
#' quadrant.
#' @examples
#' # pivot calculus scores per surface (all columns except id)
#'   # 't' prefix needs to be removed from column names
#' mb11_calculus %>%
#'   dental_longer(-id, names_sep = "_")
#'
#' # pivot caries scores per tooth
#' mb11_caries %>%
#'   dental_longer(-id)
#' @export

dental_longer <- function(data, cols, ...){
  fn_call <- match.call()
  fn_args <- rlang::call_args(fn_call)
  surf_sep <- fn_args[["names_sep"]]
  surf_pattern <- fn_args[["names_pattern"]]
  if(!is.null(surf_sep) | !is.null(surf_pattern)){
    out <- tidyr::pivot_longer(
      data,
      {{ cols }},
      names_to = c("tooth", "surface"),
      values_to = "score",
      ...
    )
  } else {
    out <- tidyr::pivot_longer(
      data,
      {{ cols }},
      names_to = "tooth",
      values_to = "score",
      ...
    )
  }
  out
}

#' Produce detailed tooth position information from tooth notation
#'
#' @inheritParams dental_longer
#' @param notation string. Which notation convention is used to name the columns
#' with dental scores. Options are "FDI", "standards", "text". See the
#' `tooth_notation` object for more details.
#' @param by string. name of column containing the tooth notation.
#' @param ... supply additional arguments to `left_join()`
#' @return Returns the original data frame along with detailed information about
#' the tooth including, region (maxilla, mandible),
#' position (anterior, posterior), side, class (incisor, canine, etc.), type,
#' (first incisor, second molar, etc.), and quadrant.
#' @examples
#' mb11_caries %>%
#'   dental_longer(-id) %>%
#'   dental_join()
#'
#' @export

dental_join <- function(data, by = tooth, notation = c("FDI", "standards", "text"), ...){
  notation <- match.arg(notation, c("FDI", "standards", "text"))
  column_select <- c(notation, "region", "position", "side", "class", "type", "quadrant")
  tooth_notation <- tooth_notation[column_select]
  names(tooth_notation)[1] <- deparse(substitute(tooth)) # rename notation df to match input data for join
  if(notation == "text"){
    data %>%
      dplyr::left_join(tooth_notation, ...)
  } else {
    data %>%
      dplyr::mutate(across({{ by }}, \(x) stringr::str_extract(x, "\\d+"))) %>%
      dplyr::left_join(tooth_notation, ...) # need to be able to use the 'by' argument here
  }
}

#' Recode tooth notation
#'
#' Function to switch between tooth notations.
#' @param data A data frame to convert
#' @param col the column to convert. Must contain a tooth notation (e.g., FDI, standards).
#' @param from string. the tooth notation of the original data.
#' @param to string. The tooth notation you wish to convert to.
#' @export
dental_recode <- function(data, col, from, to){
    data <- strip_prefix(data, {{ col }})
    dplyr::mutate(
      data,
      "{{col}}" := plyr::mapvalues(
        {{ col }}, 
        from = tooth_notation[[from]], 
        to = tooth_notation[[to]]
      )
    )
}
