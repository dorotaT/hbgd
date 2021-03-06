#' Transform a longitudinal dataset into one row per subject
#'
#' @param dat dataset to transform
#' @examples
#' cppsubj <- by_subject(cpp)
#' @return A data frame with one row per subject with all subject-level variables remaining as regular columns and a list-column "longi" of nested data frames of the subject's longitudinal data.
#' @export
#' @importFrom tidyr nest
by_subject <- function(dat) {
  if (!has_data_attributes(dat))
    dat <- get_data_attributes(dat)

  # find subject-level variables so we don't nest them
  var_summ <- attr(dat, "hbgd")$var_summ
  subj_vars <- c("subject-level", "subject id")
  ind <- which(var_summ$type %in% subj_vars)

  group_args <- c(list(.data = dat), as.list(var_summ$variable[ind]))
  res <- do.call(dplyr::group_by_, group_args) %>%
    tidyr::nest(.key = "longi")
  class(res) <- c("subjDiv", class(res))
  res
}

# #' Split by-subject trajectory-fitted data by checkpoint categorizations
# #'
# #' @param dat a data object returned by \code{\link{fit_all_trajectories}}
# #' @param complete subset only to those that have fitted checkpoints
# #' @examples
# #' \dontrun{
# #' cppsubj <- by_subject(cpp)
# #' cppfit  <- get_fit(cpp, method = "rlm")
# #' cpptr   <- fit_all_trajectories(cppsubj, cppfit)
# #' cppcp   <- by_trajectory_checkpoints(cpptr)
# #' }
# #' @export
# by_trajectory_checkpoints <- function(dat, complete = TRUE) {

#   # should be one row for each subject id
#   check_by_subject(dat)

#   n_rec <- length(dat)
#   message("* Filtering out subjects that didn't have enough data to fit at checkpoints...")

#   # subset only to those that have fitted checkpoints
#   dat <- datadr::drFilter(dat, function(x) {
#     if (is.null(x$checkpoint))
#       return(FALSE)
#     if (complete && (is.null(x$checkpoint$zcat) || any(is.na(x$checkpoint$zcat))))
#       return(FALSE)
#     TRUE
#   }, params = list(complete = complete)) # nolint

#   n_rec2 <- length(dat)

#   if (n_rec != n_rec2)
#     message("* Went from ", n_rec, " to ", n_rec2, " subjects.")

#   res <- dat %>% datadr::addTransform(function(x) {
#     v <- x$data
#     v$subjid <- datadr::getSplitVar(x, "subjid")

#     keys <- paste0(x$checkpoint$x, "=", x$checkpoint$zcat)
#     splitdf <- data.frame(t(keys), stringsAsFactors = FALSE)
#     names(splitdf) <- paste0("checkpoint", seq_along(keys))
#     attr(v, "split") <- splitdf

#     datadr::kvPair(
#       k = paste(keys, collapse = "|"),
#       v = v
#     )
#   })
#   datadr::recombine(res, datadr::combDdf)
# }
