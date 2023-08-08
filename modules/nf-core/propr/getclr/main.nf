process PROPR_GETCLR {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::r-propr=4.2.6"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-propr:4.2.6':
        'biocontainers/r-propr:4.2.6' }"

    input:
<<<<<<< Updated upstream
    tuple val(meta), path(matrix_in)
=======
    tuple val(meta), path(count)
>>>>>>> Stashed changes
    //val(meta) because inputs are sample specific

    output:
    tuple val(meta), path("*_clr.csv"), emit: csv
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
<<<<<<< Updated upstream
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    Rscript ${projectDir}/modules/nf-core/getclr/templates/helper.R \\
        --count_matrix $matrix_in

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(r-propr --version 2>&1) | sed 's/^.*r-propr //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
   
    """
    touch ${prefix}_clr.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(r-propr --version 2>&1) | sed 's/^.*r-propr //; s/Using.*\$//' ))
    END_VERSIONS
    """
=======
    template 'getclr.R'
>>>>>>> Stashed changes
}