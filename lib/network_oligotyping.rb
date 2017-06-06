require "parse_fasta"
require "shannon"
require "network_oligotyping/version"

module NetworkOligotyping
  def self.index_of_max_entropy arys
    ents = arys.map { |ary| Shannon::entropy ary.join }
    p ents
    max_ent = ents.max
    ents.index max_ent
  end

  def self.make_column_arrays fname
    col_arys = []
    aln_len = -1
    ParseFasta::SeqFile.open(fname).each_record do |rec|
      if aln_len == -1
        aln_len = rec.seq.length
        col_arys = Array.new(aln_len) { Array.new }
      elsif aln_len != rec.seq.length
        abort "Length of #{rec.header} was #{rec.seq.length}, " +
              "expected #{aln_len}"
      end

      rec.seq.chars.map.with_index do |char, idx|
        # TODO check bounds of this idx
        col_arys[idx] << char.upcase
      end
    end
  end
end
