mb11_calculus_long <- mb11_calculus %>%
  dental_longer(-id, names_sep = "_")

mb11_caries_long <- mb11_caries %>%
  dental_longer(-id)

test_that("notation can be converted", {
  new_notation <- mb11_caries_long |>
    dental_recode(col = tooth, from = "FDI", to = "standards")

  expect_equal(dim(new_notation), dim(mb11_caries_long))
  expect_in(new_notation$tooth, tooth_notation$standards)
})

test_that("dental_longer works", {
  expect_equal(nrow(mb11_calculus_long), nrow(mb11_calculus) * 96)
  expect_equal(nrow(mb11_caries_long), nrow(mb11_caries) * 32)
})

test_that("dental_join works", {
  calc_join <- mb11_calculus_long %>%
    dental_join()
  caries_join <- mb11_caries_long %>%
    dental_join()
  expect_equal(sum(is.na(calc_join$region)), 0)
  expect_equal(sum(is.na(calc_join$position)), 0)
  expect_equal(sum(is.na(caries_join$region)), 0)
  expect_equal(sum(is.na(caries_join$position)), 0)
})
