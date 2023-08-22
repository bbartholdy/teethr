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
#' @param data A data frame containing one column with a unique identifier and
#' multiple columns with calculus scores from each surface of a tooth.
#' @param cols Which columns to pivot into longer format. These should be the columns
#' containing the scores for each tooth/surface.
#' @param ... additional arguments passed on to \code{\link[tidyr]{pivot_longer}}.
#' @param notation string. Which notation convention is used to name the columns
#' with dental scores. Options are "FDI", "standards1994", "text". See the
#' `tooth_notation` object for more details.
#' @param rm_char string. Optional argument to remove any characters from tooth
#' name columns, e.g., if the FDI number was prefixed with a letter (since it's not
#' great practice to have column names in a spreadsheet starting with a number).
#' @return Returns a longer data frame with one row per tooth or tooth surface,
#' with columns for tooth number, region (maxilla, mandible),
#' position (anterior, posterior), side, class (incisor, canine, etc.), type, and
#' quadrant.
#' @examples
#' # pivot calculus scores per surface (all columns except id)
#'   # 't' prefix needs to be removed from column names
#' mb11_calculus %>%
#'   dental_longer(-id, rm_char = "t", names_sep = "_")
#'
#' # pivot caries scores per tooth
#' mb11_caries %>%
#'   dental_longer(-id, rm_char = "t")
#' @export

dental_longer <- function(data, cols, ...,
                          notation = c("FDI", "standards1994", "text"), rm_char = NULL){
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
  out_pos <- dental_join(out, notation = notation, rm_char = rm_char)
  if(sum(is.na(out_pos$region)) > 0) stop("Could not recognise dental notation. Make sure you are using one of the supported methods (FDI, standards1994, text).
    rm_char can be used to identify any characters that need to be removed from the dental notation (supports regex).")
  out_pos
}

#' Produce detailed tooth position information from tooth notation
#'
#' @inheritParams dental_longer
#' @return Returns the original data frame along with detailed information about
#' the tooth including, region (maxilla, mandible),
#' position (anterior, posterior), side, class (incisor, canine, etc.), type,
#' (first incisor, second molar, etc.), and quadrant.

dental_join <- function(data, notation = NULL, rm_char = NULL){
  notation <- match.arg(notation, c("FDI", "standards1994", "text"))
  column_select <- c(notation, "region", "position", "side", "class", "type", "quadrant")
  tooth_notation <- tooth_notation[column_select]
  data %>%
    {if(!is.null(rm_char)) dplyr::mutate(., tooth = stringr::str_remove(tooth, rm_char)) else .} %>%
    dplyr::left_join(tooth_notation, c("tooth" = notation))
}
