#' Estimate Covariance Parameters
#'
#' Used to estimate spatial covariance parameters for a few different spatial models, including the Exponential, Gaussian, and Spherical.
#' Estimated parameters can then be used in \code{predict} to predict unobserved values.
#'
#' The function is used internally in \code{slmfit}.
#'
#' @param response a vector of a response variable, possibly with
#' missing values.
#' @param designmatrix is the matrix of covariates used to regress
#' the response on.
#' @param xcoordsvec is a vector of x coordinates
#' @param ycoordsvec is a vector of y coordinates
#' @param CorModel is the covariance structure. By default, \code{covstruct} is
#' @param estmethod is either the default \code{"REML"} for restricted
#' maximum likelihood to estimate the covariance parameters and
#' regression coefficients or \code{"ML"} to estimate the covariance
#' parameters and regression coefficients.
#' Exponential but other options include the Spherical and the Gaussian.
#' @param covestimates is an optional vector of covariance parameter estimates (nugget, partial sill, range). If these are given and \code{estmethod = "None"}, the the provided vector are treated as the estimators to create the covariance structure.
#' @param pivec is a vector of estimated detection probabilities
#' on each of the sites
#' @param Vnn is the covariance matrix for the estimated detection
#' probabilities
#' @return a list with \itemize{
#'    \item a vector of estimated covariance parameters
#'    \item the estimated covariance matrix for all sites
#'    \item the QR decomposition
#'    \item a vector of estimated fixed effects
#'    \item other components used in \code{slmfit}
#' }
#' @export estcovparm



estcovparm <- function(response, designmatrix, xcoordsvec, ycoordsvec,
  CorModel = "Exponential", estmethod = "REML",
  covestimates = c(NA, NA, NA),
  pivec = NA,
  Vnn = NA) {
  
  ## only estimate parameters using sampled sites only
  
  ind.sa <- !is.na(response)
  designmatrixsa <- as.matrix(designmatrix[ind.sa, ])
  
  
  names.theta <- c("nugget", "parsil", "range")
  
  ## eventually will expand this section to include other covariance types
  if(CorModel == "Cauchy" || CorModel == "BesselK"){
    names.theta <- c(names.theta, "extrap")
  }
  
  nparm <- length(names.theta)
  
  n <- length(response[ind.sa])
  p <- ncol(designmatrix)
  
  
  ## distance matrix for all of the sites
  distmatall <- matrix(0, nrow = nrow(designmatrix),
    ncol = nrow(designmatrix))
  distmatall[lower.tri(distmatall)] <- stats::dist(as.matrix(cbind(xcoordsvec, ycoordsvec)))
  distmatall <- distmatall + t(distmatall)
  
  ## constructing the distance matrix between sampled sites only
  sampdistmat <- matrix(0, n, n)
  sampdistmat[lower.tri(sampdistmat)] <- stats::dist(as.matrix(cbind(xcoordsvec[ind.sa], ycoordsvec[ind.sa])))
  distmat <- sampdistmat + t(sampdistmat)
  
  if (anyNA(pivec) == TRUE & anyNA(Vnn) == TRUE) {
  
  if (estmethod == "None") {
    
    possible_nug_prop <- covestimates[1] /
      (covestimates[1] + covestimates[2])
    possible.theta1 <- log(possible_nug_prop /
        (1 - possible_nug_prop))
    possible.range <- covestimates[3]
    possible.theta2 <- log(possible.range)
    theta <- c(possible.theta1, possible.theta2)
    
    m2loglik <- m2LL.FPBK.nodet(theta = theta,
      zcol = response[ind.sa],
      XDesign = as.matrix(designmatrixsa),
      xcoord = xcoordsvec[ind.sa], ycoord = ycoordsvec[ind.sa],
      CorModel = CorModel,
      estmethod = "ML")
    
    loglik <- -m2loglik
    
    nug_prop <- possible_nug_prop
    range.effect <- possible.range
  } else {
    
    possible_nug_prop <- c(0.25, 0.5, 0.75)
    possible.theta1 <- log(possible_nug_prop /
        (1 - possible_nug_prop))
    possible.range <- c(max(distmat), max(distmat) / 2, max(distmat) / 4)
    possible.theta2 <- log(possible.range)
    theta <- expand.grid(possible.theta1, possible.theta2)
    
    m2loglik <- rep(NA, nrow(theta))
    
    
    for (i in 1:nrow(theta)) {
      m2loglik[i] <- m2LL.FPBK.nodet(theta = theta[i, ],
        zcol = response[ind.sa],
        XDesign = as.matrix(designmatrixsa),
        xcoord = xcoordsvec[ind.sa], ycoord = ycoordsvec[ind.sa],
        CorModel = CorModel,
        estmethod = estmethod)
    }
    
    max.lik.obs <- which(m2loglik == min(m2loglik))
    
    ## optimize using Nelder-Mead
    parmest <- optim(theta[max.lik.obs, ], m2LL.FPBK.nodet,
      zcol = response[ind.sa],
      XDesign = as.matrix(designmatrixsa),
      xcoord = xcoordsvec[ind.sa], ycoord = ycoordsvec[ind.sa],
      method = "Nelder-Mead",
      CorModel = CorModel, estmethod = estmethod)
    
    ## extract the covariance parameter estimates. When we deal with covariance
    ## functions with more than 3 parameters, this section will need to be modified
    min2loglik <- parmest$value
    loglik <- -min2loglik
    
    # nugget.effect <- exp(parmest$par[1])
    # parsil.effect <- exp(parmest$par[2])
    # range.effect <- exp(parmest$par[3])
    # parms.est <- c(nugget.effect, parsil.effect, range.effect)
    
    nug_prop <- exp(parmest$par[1]) / (1 + exp(parmest$par[1]))
    range.effect <- exp(parmest$par[2])
    
  }
  
  #get overall variance parameter
  if (CorModel == "Exponential") {
    Sigma <- (1 - nug_prop) *
      corModelExponential(distmatall, range.effect) +
      diag(nug_prop, nrow = nrow(distmatall))
  } else if (CorModel == "Gaussian") {
    Sigma <- (1 - nug_prop) *
      (corModelGaussian(distmatall, range.effect)) +
      diag(nug_prop, nrow = nrow(distmatall))
  } else if (CorModel == "Spherical") {
    Sigma <-  (1 - nug_prop) *
      corModelSpherical(distmatall, range.effect) +
      diag(nug_prop, nrow = nrow(distmatall))
  }
  
  ## diagonalization to stabilize the resulting covariance matrix
  if (nug_prop < 0.0001) {
    Sigma <- Sigma + diag(1e-6, nrow = nrow(Sigma))
  }
  
  # #get Sigma for sampled sites only
  Sigma_samp = Sigma[ind.sa, ind.sa]
  
  
  qrV <- qr(Sigma_samp)
  ViX <- solve(qrV, as.matrix(designmatrixsa))
  covbi <- crossprod(as.matrix(designmatrixsa), ViX)
  covb <- mginv(covbi, tol = 1e-21)
  b.hat <- covb %*% t(as.matrix(designmatrixsa)) %*%
    solve(qrV, response[ind.sa])
  r <- response[ind.sa] - as.matrix(designmatrixsa) %*% b.hat
  
  sill <- as.numeric(crossprod(r, solve(qrV, r))) / n
  
  if (estmethod == "None") {
    sill <- covestimates[1] + covestimates[2]
  }
  
  if(estmethod == "ML" | estmethod == "None") {
    min2loglik <- n * log(sill) + sum(log(abs(diag(qr.R(qrV))))) +
      as.numeric(crossprod(r, solve(qrV, r))) / sill + n * log(2 * pi)
  }
  
  if(estmethod == "REML") {
    
    sill = n * sill/(n - p)
    min2loglik = (n - p) * log(sill) +
      sum(log(abs(diag(qr.R(qrV))))) +
      as.numeric(crossprod(r, solve(qrV,r))) / sill +
      (n - p) * log(2 * pi) +
      sum(log(svd(covbi)$d))
  }
  
  
  
  Sigma <- sill * Sigma
  parms.est <- c(nug_prop * sill, (1 - nug_prop) * sill,
    range.effect)
  
  return(list(parms.est = parms.est, Sigma = Sigma, qrV = qrV,
    b.hat = b.hat, covbi = covbi, covb = covb,
    min2loglik = min2loglik))
  
  } else {
    
    pivecsa <- pivec[ind.sa]
    Vnnsa <- Vnn[ind.sa, ind.sa]
    
    zhat <- response[ind.sa] / pivecsa
    
    possible.nugget <- c(var(zhat) / 4, var(zhat), var(zhat) / 2)
    possible.theta1 <- log(possible.nugget)
    
    possible.parsil <- c(var(zhat) / 4, var(zhat), var(zhat) / 2)
    possible.theta2 <- log(possible.parsil)
    
    possible.range <- c(median(distmat) / 2, median(distmat),
      max(distmat))
    possible.theta3 <- log(possible.range)
    
    theta <- expand.grid(possible.theta1, possible.theta2,
     possible.theta3)
    
 
    
      betaordinary <- as.vector(solve(t(as.matrix(designmatrixsa)) %*%
          as.matrix(designmatrixsa)) %*%
        t(as.matrix(designmatrixsa)) %*% zhat)
      thetarest <- matrix(betaordinary, nrow = nrow(theta),
        ncol = length(betaordinary), byrow = TRUE)
      
      theta <- as.matrix(cbind(theta, thetarest))
  
    
    m2loglik <- rep(NA, nrow(theta))
    val.ML.bin <- NULL; lik.val.ML.bin <- NULL
    
    
    for (i in 1:nrow(theta)) {
      m2loglik[i] <- m2LL.FPBK.det(theta = theta[i, ],
        zcol = response[ind.sa],
        XDesign = as.matrix(designmatrixsa),
        xcoord = xcoordsvec[ind.sa], ycoord = ycoordsvec[ind.sa],
        CorModel = CorModel,
        pivec = pivecsa,
        Vnn = Vnnsa)
    }
    
    max.lik.obs <- sample(which(m2loglik == min(m2loglik)),
      size = 1)
    
    ## optimize using Nelder-Mead
    parmest <- optim(theta[max.lik.obs, ], m2LL.FPBK.det,
      zcol = response[ind.sa],
      XDesign = as.matrix(designmatrixsa),
      xcoord = xcoordsvec[ind.sa], ycoord = ycoordsvec[ind.sa],
      method = "Nelder-Mead",
      CorModel = CorModel, pivec = pivecsa,
      Vnn = Vnnsa)
    
    
    ## extract the covariance parameter estimates. When we deal with covariance
    ## functions with more than 3 parameters, this section will need to be modified
    min2loglik <- parmest$value
    loglik <- -min2loglik
    
    nugget.effect <- exp(parmest$par[1])
    parsil.effect <- exp(parmest$par[2])
    range.effect <- exp(parmest$par[3])
    parms.est <- c(nugget.effect, parsil.effect, range.effect)
    nug_prop <- nugget.effect / (nugget.effect + parsil.effect)
    sill <- nugget.effect + parsil.effect
    
  
  #get overall variance parameter
  if (CorModel == "Exponential") {
    Sigma <- (1 - nug_prop) *
      corModelExponential(distmatall, range.effect) +
      diag(nug_prop, nrow = nrow(distmatall))
  } else if (CorModel == "Gaussian") {
    Sigma <- (1 - nug_prop) *
      (corModelGaussian(distmatall, range.effect)) +
      diag(nug_prop, nrow = nrow(distmatall))
  } else if (CorModel == "Spherical") {
    Sigma <-  (1 - nug_prop) *
      corModelSpherical(distmatall, range.effect) +
      diag(nug_prop, nrow = nrow(distmatall))
  }
  
  ## diagonalization to stabilize the resulting covariance matrix
  if (nug_prop < 0.0001) {
    Sigma <- Sigma + diag(1e-6, nrow = nrow(Sigma))
  }
  
    Sigma <- Sigma * sill
    
  # #get Sigma for sampled sites only
  Sigma_samp = Sigma[ind.sa, ind.sa]
  
  
  ##qrV <- qr(Sigma_samp)
  ##ViX <- solve(qrV, as.matrix(designmatrixsa))
  ##covbi <- crossprod(as.matrix(designmatrixsa), ViX)
  ##covb <- mginv(covbi, tol = 1e-21)
  ##b.hat <- covb %*% t(as.matrix(designmatrixsa)) %*%
    ##solve(qrV, response[ind.sa])
  b.hat <- as.vector(parmest$par[4:ncol(theta)])
  r <- response[ind.sa] - (as.matrix(designmatrixsa) %*% b.hat) *
    pivecsa
  
  ## sill <- as.numeric(crossprod(r, solve(qrV, r))) / n
  parms.est <- c(nugget.effect, parsil.effect,
    range.effect)
  
  return(list(parms.est = parms.est, Sigma = Sigma, qrV = NA,
    b.hat = b.hat, covbi = NA, covb = NA,
    min2loglik = min2loglik))
  
  }
}

# counts <- c(1, NA, NA, NA, 3, 1:13, 21, 30)
# pred1 <- runif(20, 0, 1); pred2 <- rnorm(20, 0, 1)
# xcoords <- runif(20, 0, 1); ycoords <- runif(20, 0, 1)
# dummyvar <- runif(20, 0, 1)
# CorModel = "Exponential"
# xcoordssamp <- xcoords[is.na(counts) == FALSE]
# ycoordssamp <- ycoords[is.na(counts) == FALSE]
# data <- as.data.frame(cbind(counts, pred1, pred2, xcoords, ycoords, dummyvar))
#
# Xdesigntest <- model.matrix(~ pred1 + pred2, data = data, na.rm = FALSE)
# formula <- counts ~ pred1 + pred2
# formula <- counts ~ 1 
# Xdesigntest <- model.matrix(~ 1, data = data, na.rm = FALSE)

##estcovparm(response = counts, designmatrix = Xdesigntest,
## xcoordsvec = xcoords,
##  ycoordsvec = ycoords, CorModel = "Gaussian")[[3]]
