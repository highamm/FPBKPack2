#' Prints the summary of a fitted spatial linear model
#'
#' @param x is an object generated from \code{\link{slmfit}}
#' @param digits is the number of digits to be displayed in the
#' model output
#' @param signif.stars is an option to show which predictors
#' are significant.
#' @param ... are options passed on to \code{printCoefmat}
#'  \code{summary.slmfit}.
#' @return a list with \itemize{
#'   \item model formula
#'   \item summary statistics for the residuals.
#'   \item a table of fixed effects estimates and associated standard errors.
#'   \item estimated spatial covariance parameter estimates.
#' }
#' @import stats
#' @export

print.summary.slmfit <- function(x,
  digits = max(3L, getOption("digits") - 3L),
  signif.stars = getOption("show.signif.stars"), ...) {
  
  
  cat("\nCall:\n", paste(deparse(x$catCall),
    sep = "\n", collapse = "\n"),
    "\n", sep = "")
  
  cat("\nResiduals:\n")
  resQ = c(min(x$Residuals), quantile(x$Residuals,
    p = c(0.25, 0.5, 0.75),
    na.rm = TRUE), max(x$Residuals))
  names(resQ) <- c("Min", "1Q", "Median", "3Q", "Max")
  print(resQ, digits = digits)
  
  cat("\nCoefficients:\n")
  coefs = x$FixedEffects
  colnames(coefs) = c("Estimate", "Std. Error", "t value", "Pr(>|t|)")
  printCoefmat(coefs, digits = digits, signif.stars = signif.stars,
    na.print = "NA", ...)
  
  cat("\nCovariance Parameters:\n")
  print(x$CovarianceParms)
  
}

print.slmfit <- function(x,...) {
  print(summary(x,...))
}