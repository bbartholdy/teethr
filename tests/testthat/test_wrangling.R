mb11_calculus_long <- mb11_calculus %>%
  dental_longer(-id, names_sep = "_", rm_char = "t")

mb11_caries_long <- mb11_caries %>%
  dental_longer(-id, rm_char = "t")

test_that("Test dental_longer function", {
  expect_error(
    mb11_caries_long %>%
      dental_longer(-id),
  "Could not recognise dental notation"
  )
  expect_equal(nrow(mb11_calculus_long), nrow(mb11_calculus) * 96)
  expect_equal(nrow(mb11_caries_long), nrow(mb11_caries) * 32)
  expect_equal(sum(is.na(mb11_calculus_long$region)), 0)
  expect_equal(sum(is.na(mb11_calculus_long$position)), 0)
  expect_equal(sum(is.na(mb11_caries_long$region)), 0)
  expect_equal(sum(is.na(mb11_caries_long$position)), 0)
})
