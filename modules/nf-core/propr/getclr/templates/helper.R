library(propr)
library(argparser)

pa <- argparser::arg_parser("Take a matrix and apply clr transformation")
pa <- argparser::add_argument(pa, "--count_matrix", type = "character", help = "Path of the input matrix")
pa <- argparser::add_argument(pa, "--output_matrix", type = "character", help = "Path of the output matrix")
pa <- argparser::parse_args(pa)

#Read matrix
matrix <- read.table(pa$count_matrix, header = TRUE, sep = ",")

#Apply CLR transformation
matrix_out <- propr:::proprCLR(matrix[, -1])

#Write resut
write.table(matrix_out, file = pa$output_matrix, sep = ",", row.names = FALSE, quote = FALSE)