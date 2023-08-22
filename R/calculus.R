#' Calculate calculus index
#'
#' Convenience function to calculate dental calculus index directly from a
#' `dental_longer()` output.
#'
#' @details Calculate the calculus index for each quadrant of an individual based
#' on the method outlined in Greene et al. (2005). The original method calculates
#' a score for each quadrant of the dentition, so it is recommended to group by
#' quadrant, either in the function or using \code{\link[dplyr]{group_by}} above in a pipe (see examples).
#' @param .data Data frame in long format, with one tooth surface per row, and one calculus score per surface.
#' @param .score numeric. Calculus score for each surface. Defaults to 'score' as provided by [dental_longer].
#' @param .method string. Using `.method = "greene2005"` will apply `dental_filter()`
#' and add `quadrant` to grouping variables (according to Greene et al. (2005)).
#' `.method = "simple"` (default) just takes user input and no filter.
#' @param ... can be used to add arguments to \code{\link[dplyr]{group_by}}. By default .add = T.
#' @return The default returns a data frame with the supplied groups and calculations
#' for number of surfaces scored, number of teeth scored, sum of scores, and the
#' calculus index.
#' @examples
#' library(dplyr)
#' mb11_calculus_long <- mb11_calculus %>%
#'   dental_longer(-id, rm_char = "t", names_sep = "_")
#' # example adding groups before call to function
#' mb11_calculus_long %>%
#'   group_by(id, quadrant) %>%
#'   calculus_index()
#'
#' # example adding groups in call to function
#' mb11_calculus_long %>%
#'   calculus_index(id, quadrant)
#'
#' # example of the Greene et al. 2005 method
#' mb11_calculus_long %>%
#'   calculus_index(.method = "greene2005")
#' @source {Greene, T.R., Kuba, C.L., Irish, J.D. 2005. Quantifying calculus: A suggested new approach for recording an important indicator of diet and dental health.} \doi{10.1016/j.jchb.2005.02.002}
#' @export

calculus_index <- function(.data, ..., .score = score, .method = c("simple", "greene2005")){
  method <- match.arg(.method, c("simple", "greene2005"))
  if(method != "greene2005" & method != "simple") stop(".method must be one of 'greene2005' or 'simple'")
  if(method == "greene2005"){
    .data %>%
      #{if(!is.null(group_vars(.data))) dplyr::group_by(., ..., quadrant, .add = T) else group_by(., quadrant, .add = T) } %>%
      # minimally, each surface must be scorable on at least one side of the dentition
      dental_filter(score = {{ .score }}) %>%
      dplyr::group_by(..., quadrant, .add = T) %>%
      dental_index(score = {{ .score }})
  } else {
  .data %>%
    group_by(..., .add = T) %>%
    dental_index(score = {{ .score }}) #%>%
  }

}

#' Dentition filter
#'
#' Checks if the data frame satisfies the criterion that minimally, each surface
#' must be scorable on at least one side of the dentition to obtain the index,
#' then filters out groups that don't satisfy.
#'
#' @inheritParams dental_index
#' @return Returns a filtered data frame and a warning if any rows were removed.
#' @export

dental_filter <- function(data, score = score){
  # Minimally, each surface must be scorable on at least one side of the dentition to obtain the index.
  # interpreted as: each surface (bucc, lin, ipx) must be represented at least once in a quadrant
  # add column on whether tooth is present or absent
  data_groups <- group_vars(data)
  exclude <- data %>%
    dplyr::mutate(
      presence = dplyr::case_when(
        is.na( {{ score }} ) ~ 0,
        TRUE ~ 1
      )
    ) %>%
    dplyr::group_by(across(group_vars(data)), quadrant, surface, .add = F) %>%
    dplyr::summarise(n_surfaces = sum(presence)) %>%
    dplyr::filter(n_surfaces == 0) %>%
    dplyr::ungroup()

  excluded_quads <- dplyr::distinct(exclude, across(group_vars(data)), quadrant)
  excluded_ids <- dplyr::distinct(exclude, across(group_vars(data)))

  if(nrow(excluded_quads) > 0 & nrow(excluded_quads < 5)) warning(sprintf("quadrant %s from id %s removed due to missing surfaces\n", excluded_quads$quadrant, excluded_quads$id))
  if(nrow(excluded_quads) > 5) warning(sprintf("%s individuals and %s quadrants removed due to missing surfaces", nrow(excluded_ids), nrow(excluded_quads)))

  out <-   data %>%
    dplyr::anti_join(excluded_quads, by = c(data_groups))
  out
}

