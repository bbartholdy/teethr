#' Convert between tooth notations
#'
#' Function to switch between tooth notations.
#' @param data A data frame to convert
#' @param tooth_cols the column(s) to convert. If the data are in long format,
#' i.e., one row per tooth, this should be a single column. If the data are in
#' wide format, this should be a ([dplyr::dplyr_tidy_select]) selection of columns.
#' @param from string. the tooth notation from the original data.
#' @param to string. The tooth notation you wish to convert to.
#' @export
convert_notation <- function(data, tooth_cols, from, to){
  # issues: premolar notation (P1 & P2 vs. P3 & P4)
    # doesn't work if not all teeth are present (at least not the wide form)

  from_vec <- tooth_notation[[from]]
  to_vec <- tooth_notation[[to]]

  n_vars <- ncol(dplyr::select(data, {{ tooth_cols }})) # there must be a better way...
  if(n_vars == 1){
    # rename with mutate
    names(to_vec) <- from_vec
    renamed_data <- dplyr::mutate(
      data,
      "{tooth_cols}" := recode_vector({{ tooth_cols }}, index = to_vec)
    )
  } else {
    if(from == "FDI"){
      from_vec <- paste0("T", from_vec)
      #print(from_vec)
      data <- dplyr::rename_with(
        data,
        \(x) paste0("T", stringr::str_extract(x, "\\d+")),
        .cols = {{ tooth_cols }}
      )
      #print(data)
    } else if(from == "text"){
      data <- data
      #data <- rename_with(data, \(x) stringr::str_to_upper(x), .cols = tooth_cols) # unknown issue here (Error: object 'URM3' not found)
    }
    names(from_vec) <- to_vec # create named vector for conversion (from = value, to = name)
    renamed_data <- rename(data, all_of(from_vec))
    #  }
  }
  return(renamed_data)
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
