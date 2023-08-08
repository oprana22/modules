#!/usr/bin/env Rscript


################################################
################################################
## Functions                                  ##
################################################
################################################

#' Flexibly read CSV or TSV files
#'
#' @param file Input file
#' @param header Boolean. TRUE if first row is header. False without header.
#' @param row.names The first column is used as row names by default. 
#' Otherwise, give another number. Or use NULL when no row.names are present.
#' 
#' @return output Data frame
read_delim_flexible <- function(file, header = TRUE, row.names = 1, check.names = TRUE){

    ext <- tolower(tail(strsplit(basename(file), split = "\\\\.")[[1]], 1))

    if (ext == "tsv" || ext == "txt") {
        separator <- "\\t"
    } else if (ext == "csv") {
        separator <- ","
    } else {
        stop(paste("Unknown separator for", ext))
    }

    read.delim(
        file,
        sep = separator,
        header = header,
        row.names = row.names,
        check.names = check.names
    )
}


#' Check if a variable can be numeric or not
#' 
#' @param x Input variable
#' @retur True if it can be numeric, False otherwise
can.be.numeric <- function(x) {
    stopifnot(is.atomic(x) || is.list(x)) # check if x is a vector
    numNAs <- sum(is.na(x))
    numNAs_new <- suppressWarnings(sum(is.na(as.numeric(x))))
    return(numNAs_new == numNAs)
}


################################################
################################################
## Parse arguments                            ##
################################################
################################################

opt <- list(
    input  = '$count',
    prefix = ifelse('$task.ext.prefix' == 'null', '$meta.id', '$task.ext.prefix')
)

################################################
################################################
## Finish loading libraries                   ##
################################################
################################################

library(propr)


################################################
################################################
## Compute CLR transformation                 ##
################################################
################################################


# read matrix
mat = read_delim_flexible(opt\$input)

# check zeros
# log transformation should be applied on non-zero data
# otherwise Inf values are generated
if (any(mat == 0)) stop("There are missing values in the input matrix. Please handle the zeros before running this script")


# clr transformation
clr = propr:::proprCLR(mat)


################################################
################################################
## Generate outputs                           ##
################################################
################################################


write.table(
    clr,
    file = paste0(opt\$prefix, '_clr.csv'),
    col.names = TRUE,
    row.names = TRUE,
    sep = ',',
    quote = FALSE
)


################################################
################################################
## R SESSION INFO                             ##
################################################
################################################

sink(paste0(opt\$prefix, ".R_sessionInfo.log"))
print(sessionInfo())
sink()


################################################
################################################
## VERSIONS FILE                              ##
################################################
################################################

r.version <- strsplit(version[['version.string']], ' ')[[1]][3]
propr.version <- as.character(packageVersion('propr'))

writeLines(
    c(
        '"${task.process}":',
        paste('    r-base:', r.version),
        paste('    r-propr:', propr.version)
    ),
'versions.yml')


################################################
################################################
################################################
################################################