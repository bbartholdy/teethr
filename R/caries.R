#' Convert caries scores to lesion counts
#'
#' @param data data frame containing caries scores
#' @param caries column containing caries scores
#' @param no_lesion value used to indicate no caries lesions
#' @param lesion_sep string. character used to separate multiple lesions.
#' @param unobs value used to indicate unobservable
#' @param method string. what method was used to score caries lesions.
#' @export

count_caries <- function(data, caries = score, no_lesion = NULL, lesion_sep = NULL, unobs = NA, method = c("location", "standards", "count")){
  method <- match.arg(method, c("location", "standards", "count"))
  if(method == "location" & is.null(no_lesion)) stop("no_lesions arg must not be empty")
  # split score into list based on lesion_sep
  #caries_split <- dplyr::mutate(data, caries_list = strsplit({{ caries }}, lesion_sep))
  if(!is.null(lesion_sep)){
    prev_groups <- dplyr::group_vars(data)
    data <- data %>%
      dplyr::ungroup() %>%
      dplyr::mutate(row_id = dplyr::row_number()) %>%
      tidyr::separate_longer_delim({{ caries }},  delim = lesion_sep) # expand data frame to one lesion per row
  }

  out <- switch(method,
         standards = standards_count(data, {{ caries }}, unobs),
         location = location_count(data, {{ caries }}, no_lesion),
         count = data)

  if(!is.null(lesion_sep)){
    out <- out %>%
      dplyr::group_by(row_id) %>%
      dplyr::mutate(caries_count = sum(caries_count)) %>%
      dplyr::distinct(row_id, .keep_all = T) %>%
      dplyr::select(!row_id) %>%
      dplyr::grouped_df(vars = prev_groups)
  }
  return(out)
}

