#!/usr/bin/env ruby

Signal.trap("PIPE", "EXIT")

require "network_oligotyping"
require "trollop"

opts = Trollop.options do
  banner <<-EOS

  Network Oligotyping!

  Options:
  EOS

  opt(:mask,
      "Mask fasta file",
      type: :string)
  opt(:alignment,
      "Alignment fasta file",
      type: :string)
  opt(:otu_calls,
      "OTU calls (ZetaHunter otu calls)",
      type: :string)
  opt(:otu_network,
      "OTU network (ZetaHunter edges file)",
      type: :string)
  # opt(:outdir, "Output directory", type: :string, default: ".")
end

############################

otu = "otu a"

mask =
  NetworkOligotyping::read_mask opts[:mask]
printf "mask: %s\n", mask

col_arys =
  NetworkOligotyping::make_column_arrays opts[:alignment]
printf "col_arys: %s\n", col_arys

masked_idx =
  NetworkOligotyping::index_of_max_entropy col_arys, mask
printf "masked_idx full: %s\n", masked_idx

otu2seqs =
  NetworkOligotyping::read_otu_calls opts[:otu_calls]
printf "otu2seqs: %s\n", otu2seqs

seq2idx =
  NetworkOligotyping::make_seq_to_idx opts[:alignment]
printf "seq2idx: %s\n", seq2idx

otu_indices =
  NetworkOligotyping::otu_indices otu, otu2seqs, seq2idx
printf "otu_indices: %s\n", otu_indices.inspect

col_arys_for_key_otu =
  NetworkOligotyping::subset_col_arys_by_seq_idx col_arys, otu_indices
printf "col_arys_for_key_otu: %s\n", col_arys_for_key_otu

masked_idx =
  NetworkOligotyping::index_of_max_entropy col_arys_for_key_otu, mask
printf "masked_idx for key otu: %s\n", masked_idx

##############

puts;puts

graph = NetworkOligotyping::Graph.read_graph opts[:otu_network]
p graph
