% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FPBKoutput.R
\name{FPBKoutput}
\alias{FPBKoutput}
\title{Create maps and summaries from FPBK results.}
\usage{
FPBKoutput(pred_info, conf_level = c(0.8, 0.9, 0.95),
  get_krigmap = TRUE, get_sampdetails = TRUE, get_variogram = TRUE,
  pointsize = 2)
}
\arguments{
\item{pred_info}{is the output from \code{FPBK.pred} in this package.}

\item{conf_level}{is the desired confidence level for the prediction. If \code{conf_level} is a vector, then confidence intervals for 
each element of the vector will be produced.}

\item{get_krigmap}{is an indicator for whether or not a grid of
the kriged responses is returned}

\item{get_sampdetails}{is an indicator for whether or not a summary
of the sampled counts should be output. This summary includes 
the total number of animals or plants sited, the total area 
surveyed, the number of sampled sites, the total number of sites,
etc.}

\item{get_variogram}{is an indicator for whether or not
a variogram of the residuals should be returned}

\item{pointsize}{is the size of the points on the spatial graphic.}
}
\value{
\itemize{
  \item prediction for the total with prediction intervals
  \item a map of the kriged counts (optional)
  \item a summary of the sample data (optional)
  \item an empirical variogram from \code{gstat} with the fitted variogram model with details of the empirical variogram and spatial parameter estimates (optional)
  \item a data frame with the site-by-site predictions
}
}
\description{
The main purpose of this function is to take the results from FPBK and make
readable maps, a fitted variogram plot, and normal-based prediction intervals. The main input for this function is the output from the \code{FPBK.pred} function.
}
\examples{
slmfitobj <- slmfit(formula = Moose ~ CountPred + Stratum,
data = vignettecount,
xcoordcol = "Xcoords", ycoordcol = "Ycoords")
predobj <- predict(object = slmfitobj)
FPBKoutput(pred_info = predobj)
}
