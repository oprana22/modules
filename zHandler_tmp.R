#!/usr/bin/env Rscript

################################################
################################################
## Parse arguments                            ##
################################################
################################################


#' Parse out optional arguments from a string without recourse to optparse
#'
#' @param x Long-form argument list like --opt1 val1 --opt2 val2
#'
#' @return named list of options and values similar to optparse
parse_args <- function(x){
    args_list <- unlist(strsplit(x, ' ?--')[[1]])[-1]
    args_vals <- lapply(args_list, function(x) scan(text=x, what='character', quiet = TRUE))

    # Ensure the option vectors are length 2 (key/ value) to catch empty ones
    args_vals <- lapply(args_vals, function(z){ length(z) <- 2; z})

    parsed_args <- structure(lapply(args_vals, function(x) x[2]), names = lapply(args_vals, function(x) x[1]))
    parsed_args[! is.na(parsed_args)]
}

# Set defaults and classes
opt <- list(
    input = NULL,
    output = NULL,
    logfile = NULL,
    header = TRUE,
    row.names = NULL
)
opt_types <- list(
    input = 'character',
    output = 'character',
    logfile = 'character',
    header = 'logical',
    row.names = 'integer'
)

# Apply parameter overrides
args_opt <- paste(commandArgs(trailingOnly = TRUE), collapse=' ')
args_opt <- parse_args(args_opt)
for (ao in names(args_opt)){
    if (! ao %in% names(opt)){
        stop(paste("Invalid option:", ao))
    }else{
        # Preserve classes from defaults where possible
        args_opt[[ao]] <- as(args_opt[[ao]], opt_types[[ao]])
        opt[[ao]] <- args_opt[[ao]]
    }
}

# Check if required parameters have been provided

required_opts <- c('input', 'output', 'logfile')
missing <- required_opts[unlist(lapply(opt[required_opts], is.null)) | ! required_opts %in% names(opt)]

if (length(missing) > 0){
    stop(paste("Missing required options:", paste(missing, collapse=', ')))
}


################################################
################################################
## Functions                                  ##
################################################
################################################

#' Flexibly read CSV or TSV files
#'
#' @param file Input file
#' @param header Boolean. TRUE if first row is header. False without header.
#' @param row.names NULL if index names are not present in data. Otherwise, give the column number
#' 
#' @return output Data frame
read_delim_flexible <- function(file, header = TRUE, row.names = NULL, check.names = TRUE){

    ext <- tolower(tail(strsplit(basename(file), split = "\\.")[[1]], 1))

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


################################################
################################################
## Finish loading libraries                   ##
################################################
################################################

library(zCompositions)


################################################
################################################
## Handling zeros                             ##
################################################
################################################

# read matrix
mat = read_delim_flexible(opt$input, header = opt$header, row.names = opt$row.names, check.names = TRUE)

# Handle zeros
mat_t = cmultRepl(t(mat))

################################################
################################################
## Generate outputs                           ##
################################################
################################################


write.table(
    t(mat_t),
    file = opt$output,
    col.names = opt$header,
    row.names = ifelse(TRUE, !is.null(opt$row.names), FALSE),
    sep = ',',
    quote = FALSE
)

################################################
################################################
## R SESSION INFO                             ##
################################################
################################################

sink(opt$logfile)
print(sessionInfo())
sink()


################################################
################################################
## VERSIONS FILE                              ##
################################################
################################################

r.version <- strsplit(version[['version.string']], ' ')[[1]][3]
zCompositions.version <- as.character(packageVersion('r-zcompositions'))

writeLines(
    c(
        '"${task.process}":',
        paste('    r-base:', r.version),
        paste('    r-zcompositions:', zCompositions.version)
    ),
'versions.yml')


################################################
################################################
################################################
################################################