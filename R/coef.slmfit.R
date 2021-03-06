#' Extract Model Coefficients
#'
#' @param object a \code{\link{slmfit}} object
#' @param ... additional arguments
#' @return a vector of fitted model coefficients.
#' @export

coef.slmfit <- function(object, ...)
{
  coef.vec <- object$CoefficientEsts
  return(coef.vec)
}