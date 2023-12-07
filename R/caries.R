#' Calculate caries ratio
#'
#' Convenience function to calculate dental caries ratio directly from a
#' `dental_longer()` output.
#'
#' @details Calculate the caries ratio for each tooth type. Calculated as the number
#' of caries divided by the number of visible surfaces.
#'
#' Multiple methods are available for recording carious lesions. The function supports
#' using a string to indicate the location of a lesion(s) on each tooth/surface
#' ('location'),
#' the method outlined in Standards (Buikstra and Ubelaker 1994) ('standards'),
#' and an integer indicating the number of lesions on a tooth/surface ('count').
#' The method is #' passed to `caries_reduce()`, which reduces the recorded score
#' to presence/absence. The presence/absence is then summed to get a count for the
#' number of lesions on each tooth/surface.
#'
#' @param .data Data frame in long format, with one tooth per row, and a column with the caries count for each tooth.
#' @param .caries Caries count variable. Defaults to 'count'.
#' @param .no_lesion string used to indicate how the absence of lesions were scored.
#' @param .lesion_sep string used to indicate how multiple lesions on a tooth/surface are separated (if applicable).
#' @param .method string. The method used to score caries lesions. Supported methods are 'location', 'standards', and 'count'.
#' See 'Details' for more information.
#' @inheritParams calculus_index
#' @return Returns a data frame with caries ratio per group.
#' @examples
#' library(dplyr)
#' mb11_caries_long <- mb11_caries %>%
#'   dental_longer(-id, rm_char = "t")
#' # example adding groups before call to function
#' mb11_caries_long %>%
#'   group_by(class) %>%
#'   caries_ratio(.no_lesion = "none", .lesion_sep = ";")
#'
#' # example adding groups in call to function
#' mb11_caries_long %>%
#'   caries_ratio(class, .no_lesion = "none", .lesion_sep = ";")
#' @export

caries_ratio <- function(.data, .id_cols, ..., .caries = score, .no_lesion = NULL, .lesion_sep = NULL, .method = c("location", "standards", "count")){
  if(!is.null(.no_lesion) & !is.null(.lesion_sep)){
    .data %>%
      caries_reduce(id_cols = {{ .id_cols }}, caries = {{ .caries }}, no_lesion = .no_lesion, lesion_sep = .lesion_sep, method = .method) %>%
      dplyr::group_by(..., .add = T) %>%
      dental_ratio(count = caries_count)
  } else {
    .data %>%
      # {if(!is.null(.no_lesions) & !is.null(.lesion_sep))
      #   caries_reduce(., caries = {{ .caries }}, no_lesions = .no_lesions, lesion_sep = .lesion_sep, method = .method) %>%
      #     dental_frequency(., .count = caries_count) else .} %>%
      dplyr::group_by(..., .add = T) %>%
      dental_ratio(count = {{ .caries }})
  }
}

#' Convert caries location to presence/absence of lesion
#' @noRd

caries_reduce <- function(data, id_cols, caries = score, no_lesion = NULL, lesion_sep = NULL, method = c("location", "standards", "count")){
  method <- match.arg(method, c("location", "standards", "count"))

  # expand each lesion to its own row (needs to be recombined after presence/absence conversion)
  out_long <- tidyr::separate_longer_delim(data, {{ caries }},  delim = lesion_sep) # expand data frame to one lesion per row
  if(method == "standards"){
    out <- dplyr::mutate(
      out_long,
      caries_count = dplyr::case_when(
        {{ caries }} == 0 ~ 0,
        {{ caries }} == 7 ~ NA_integer_,
        {{ caries }} > 0 & {{ caries }} < 7 ~ 1,
        TRUE ~ {{ caries }}
      )
    )
  } else if(method == "location") {
    if(is.null(no_lesion)) stop("no_lesions arg must not be empty")
    out_bin <- dplyr::mutate(
      out_long,
      caries_count = dplyr::if_else(
        {{ caries }} == no_lesion, 0L, 1L, missing = NA # convert lesion location to binary (present = 1; absent = 0)
      )
    )
    out <- dplyr::distinct(dplyr::mutate(
      out_bin,
      caries_count = sum(caries_count),
      .by = c(id, tooth)
    ), id, tooth, .keep_all = T)
  } else if(method == "count"){
    out <- data
  }
  out
}

