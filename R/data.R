#' Middenbeemster dental calculus data
#'
#' Dental calculus scores collected from Middenbeemster (MB11), a rural 19th century
#' archaeological site in the Netherlands.
#'
#' @format ## `mb11_calculus`
#' A data frame with 41 rows and 97 columns:
#' \describe{
#'   \item{id}{Skeletal ID}
#'   \item{t11:t48_buc/lin/ipx}{Calculus score per tooth surface. Variable naming:
#'   t<tooth number (FDI notation)>_<surface>.
#'   buc = buccal; lin = lingual, ipx = interproximal}
#'   ...
#' }
#' @source https://doi.org/10.5281/zenodo.7649151
"mb11_calculus"

#' Middenbeemster dental caries data
#'
#' Dental caries lesions collected from Middenbeemster (MB11), a rural 19th century
#' archaeological site in the Netherlands.
#'
#' @format ## `mb11_caries`
#' A data frame with 41 rows and 33 columns:
#' \describe{
#'   \item{id}{Skeletal ID}
#'   \item{t11:t48}{Caries lesion location(s) per tooth. Multiple scores separated
#'   by ';'. Variable naming: t<tooth number (FDI notation)>.
#'   mes = mesial, dis = distal, buc = buccal; lin = lingual, occ = occlusal,
#'   root = root, crown = large lesion of indeterminate origin}
#'   ...
#' }
#' @source https://doi.org/10.5281/zenodo.7649151
"mb11_caries"

#' Middenbeemster sample demographics
#'
#' Age and sex of the individuals with dental calculus scored in `mb11_calculus`.
#'
#' @format ## `mb11_demography`
#' A data frame with 41 rows and 97 columns:
#' \describe{
#'   \item{id}{Skeletal ID}
#'   \item{age}{Age category of the individual. eya = early young adult (18-24);
#'   lya = late young adult (25-34); ma = middle adult (35-49); old = old adult (50+).}
#'   \item{sex}{Biological sex of individual estimated using osteological methods.
#'   f = female; pf = probable female; pm = probable male; m = male.}
#'   ...
#' }
#' @source https://doi.org/10.5281/zenodo.7649151
"mb11_demography"

#' Common naming schemes in dental anthropology
#'
#' Used to convert between tooth naming conventions that are common in dental
#' anthropology.
#' @format ## `tooth_notation`
#' A data frame with 32 rows and 9 columns:
#' \describe{
#'   \item{FDI}{Fédération dentaire internationale naming convention}
#'   \item{standards}{Standards naming (Buikstra and Ubelaker 1994)}
#'   \item{text}{Text naming: [UL][LR][ICPM][1-3] = upper/lower; left/right; incisor/canine/premolar/molar; tooth type (1-4). Example: Upper left lateral incisor = ULI2}
#'   \item{region}{if the tooth is from the maxilla or mandible}
#'   \item{position}{if the tooth is anterior or posterior}
#'   \item{side}{if the tooth is from the left or right side}
#'   \item{class}{if the tooth is incisor, canine, premolar, or molar}
#'   \item{type}{if the tooth is central/lateral incisor, canine, first/second premolar, or first/second/third molar}
#'   \item{quadrant}{Which quadrant of the mouth the tooth is from. Upper/lower anterior/posterior.}
#'   ...
#' }
#' @source Buikstra, J. E., & Ubelaker, D. H. (1994). Standards for data collection from human skeletal remains. Arkansas Archaeological Survey Research Series No. 44. Fayetteville: Arkansas Archaeological Survey.
"tooth_notation"
