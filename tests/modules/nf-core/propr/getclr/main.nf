#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PROPR_GETCLR } from '../../../../../modules/nf-core/propr/getclr/main.nf'

workflow test_propr_getclr {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    PROPR_GETCLR ( input )
}