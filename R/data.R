#' Data Set with Uncorrelated Poisson Counts.
#'
#' A data set that can be used with the \code{FPBKPack2} package. In 
#' this example, the counts are uncorrelated, the covariates are
#' generated as uniform random variables, and the sites fall on a 
#' regular grid.
#'
#' @format A data frame with 40  rows and 7 variables:
#' \describe{
#'   \item{counts}{counts, with NA values for unsampled sites}
#'   \item{pred1}{a possible predictor}
#'   \item{pred2}{a second possible predictor}
#'   \item{xcoords}{coordinates on the x-axis}
#'   \item{ycoords}{coordinates on the y-axis}
#'   \item{dummyvar}{an extra variable}
#'   \item{areavar}{Variable for the area of each plot}
#'   ...
#' }
"exampledataset"


#' Data Set with Alaska Moose Observations.
#'
#' A data set that can be used with the \code{FPBKPack2} package. In
#' this example, the counts are of moose on 860 sites of equal area.
#'
#' @format A spatial polygons object including:
#' \describe{
#'   \item{CENTRLAT}{The latitude of the centroid for each site}
#'   \item{CENTRLON}{The latitude of the centroid for each site}
#'   \item{STRAT}{A stratification variable}
#'   \item{TOTAL}{The total moose count on each site}
#'   ...
#' }
"AKmoose"

#' Simulated Data Set with Moose count observations.
#'
#' A data set that can be used with the \code{FPBKPack2} package. In
#' this example, the counts are of moose on 860 sites of equal area.
#'
#' @format A data frame object including:
#' \describe{
#'   \item{X}{ID number for the sites}
#'   \item{Xcoords}{The x coordinates of the centroid for each site}
#'   \item{Ycoords}{The y coordinates of the centroid for each site}
#'   \item{Moose}{The total moose count on each site}
#'   \item{Area}{The area of each site}
#'   \item{CountPred}{A predictor for site-by-site abundance}
#'   \item{DetPred1}{A predictor for detection}
#'   \item{DetPred2}{A second predictor for detection}
#'   \item{Stratum}{A factor with two levels, High and Low}
#'   ...
#' }
"vignettecount"

#' Simulated Data Set with Moose Radiocollar sightability observations.
#'
#' A data set that can be used with the \code{FPBKPack2} package. In
#' this example, the there are two predictors for detection.
#'
#' @format A data frame object including:
#' \describe{
#'   \item{X}{ID number for the radiocollared moose}
#'   \item{Detected}{1 if detected, 0 if not}
#'   \item{DetPred1}{A predictor for detection}
#'   \item{DetPred2}{A second predictor for detection}
#'   ...
#' }
"vignettedetection"

#' Data Set with Togiak March Moose Observatations.
#'
#' A data set that can be used with the \code{FPBKPack2} package. In
#' this example, the counts are of moose on 860 sites of equal area.
#'
#' @format A data frame object:
#' \describe{
#'   \item{centrlat}{The latitude of the centroid for each site}
#'   \item{centrlon}{The latitude of the centroid for each site}
#'   \item{Strat}{A stratification variable}
#'   ...
#' }
"MarchMoose"

#' Simulated Data Set with Moose Radiocollar sightability observations.
#'
#' A data set that can be used with the \code{FPBKPack2} package. In
#' this example, the there are two predictors for detection.
#'
#' @format A data frame object including:
#' \describe{
#'   \item{Moo.ID}{ID number for the radiocollared moose}
#'   \item{Detected.}{Y if detected, N if not}
#'   ...
#' }
"MarchSight"