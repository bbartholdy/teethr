# strip letter prefix from tooth numbers (if present)
strip_prefix <- function(data, col){
  dplyr::mutate(
    data,
    "{{ col }}" := gsub("[[:alpha:]]+", "", {{ col }})
  )
}

# convert caries scores using Standards scoring to counts
standards_count <- function(data, caries, unobs){
  out <- dplyr::mutate(data,
    caries_count = as.numeric({{ caries }}),
    caries_count = dplyr::case_when(
          caries_count == 7 ~ NA_integer_,
          caries_count > 0 & caries_count < 7 ~ 1,
          caries_count == unobs ~ NA_integer_,
          TRUE ~ caries_count
      )
    )
  return(out)
}

location_count <- function(data, caries, no_lesion){
  out <- data %>%
    dplyr::mutate(caries_count = dplyr::if_else({{ caries }} == no_lesion,
                  0, 1, missing = NA_integer_))
    return(out)
}
