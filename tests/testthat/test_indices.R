library(dplyr)
mb11_calculus_long <- mb11_calculus %>%
  dental_longer(-id, names_sep = "_") %>%
  dental_join()

## ADD TEST COMPARING CALCULATED RATIO WITH MANUAL CALCULATION

test_that("calculus index calculations work", {
  expect_warning(
    ci_calc <- mb11_calculus_long %>%
      group_by(id, quadrant) %>%
      calculus_index(),
    "rows removed because of no teeth present in groupings"
  )
  expect_warning(
    ci_calc_greene <- mb11_calculus_long %>%
      group_by(id) %>%
      calculus_index(.method = "greene2005"),
    "removed due to missing surfaces"
  )
  expect_type(mb11_calculus_long$score, "double")
  expect_gte(min(ci_calc$index), 0)
  expect_lte(max(ci_calc$index), 3)
  expect_gte(min(ci_calc$n), 0)
  expect_lte(max(ci_calc_greene$n), 30)
  expect_gte(min(ci_calc_greene$index), 0)
  expect_lte(max(ci_calc_greene$index), 3)
  expect_equal(ci_calc$score_sum / ci_calc$n, ci_calc$index)
  expect_equal(ci_calc_greene$score_sum / ci_calc_greene$n, ci_calc_greene$index)
})

test_that("caries ratio calculations work", {
  mb11_caries_long <- mb11_caries %>%
    dental_longer(-id) %>%
    dental_join()

  mb410 <- mb11_caries_long %>%
    filter(id == "MB410")
  n <- sum(!is.na(mb410$score))
  n_caries <- 8
  mb410_ratio <- 8 / n

  caries_rates_id <-  mb11_caries_long %>%
    dplyr::group_by(id) %>%
    count_caries(no_lesion = "none", lesion_sep = ";") %>%
    dental_ratio(count = caries_count)
    #caries_ratio(id, .no_lesion = "none", .lesion_sep = ";")
  #expect_equal(nrow(caries_rates_id2), nrow(mb11_caries_long))
  expect_equal(filter(caries_rates_id, id == "MB410")$ratio, mb410_ratio)
  expect_type(mb11_caries_long$score, "character")
  #expect_gte(min(caries_rates_id2$ratio), 0)
  #expect_lte(max(caries_rates_id2$n), 32)
  expect_equal(caries_rates_id$count / caries_rates_id$n, caries_rates_id$ratio)
})
