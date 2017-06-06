require "network_oligotyping"

aln_fname = ARGV[0]

col_arys = NetworkOligotyping::make_column_arrays aln_fname

idx = NetworkOligotyping::index_of_max_entropy col_arys

p col_arys
p idx
