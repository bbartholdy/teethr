library(dplyr)
mb11_calculus_long <- mb11_calculus %>%
dental_longer(-id, rm_char = "t", names_sep = "_")

# mb11_caries_long <- mb11_caries %>%
#   dental_longer(-id, rm_char = "t")
#
# caries_count <- mb11_caries_long %>%
#   caries_reduce(no_lesion = "none", lesion_sep = ";") %>%
#   #group_by(id) %>%
#   count_lesions()

test_that("Test calculus index calculations", {
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

# test_that("Test caries ratio calculations", {
#   expect_message(
#     caries_rates_id <- mb11_caries_long %>%
#       group_by(id) %>%
#       caries_ratio(.no_lesion = "none", .lesion_sep = ";"),
#     "on the data frame before using the function"
#   )
#   caries_rates_id2 <-  mb11_caries_long %>%
#     caries_ratio(id, .no_lesion = "none", .lesion_sep = ";")
#   expect_equal(nrow(caries_count), nrow(mb11_caries_long))
#   expect_equal(caries_rates_id2, caries_rates_id)
#   expect_type(mb11_caries_long$score, "character")
#   expect_gte(min(caries_rates_id$ratio), 0)
#   expect_lte(max(caries_rates_id$n), 32)
#   expect_equal(caries_rates_id$count / caries_rates_id$n, caries_rates_id$ratio)
# })
