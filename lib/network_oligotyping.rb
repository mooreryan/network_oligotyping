require "abort_if"
require "parse_fasta"
require "shannon"
require "set"

include AbortIf
include AbortIf::Assert




require "network_oligotyping/version"

module NetworkOligotyping

  # Returns the index of the position in the alignment with the
  # maximum entropy.
  #
  # @note If there is a tie, the position closest to the start of the
  #   alignment will be chosen.
  #
  # @param arys [Array<Array>] array of arrays holding columns of the
  #   alignment
  #
  # @param mask [Set] a set of positions of candidate columns of the
  #   alignment
  #
  # @return [Fixnum] the zero-based column of the alignment with the
  #   highest entropy (possibly resricted to columns in the mask)
  def self.index_of_max_entropy arys, mask=nil
    idx_max_ent = -1
    ents = arys.map { |ary| self.entropy ary }

    if mask
      idx_max_ent = self.idx_of_max_entropy_masked ents, mask
    else
      max_ent = ents.max
      idx_max_ent = ents.index max_ent
    end

    idx_max_ent
  end

  def self.make_column_arrays fname
    col_arys = []
    aln_len = -1

    ParseFasta::SeqFile.open(fname).each_record do |rec|
      if aln_len == -1
        aln_len = rec.seq.length
        col_arys = self.make_col_arrays aln_len
      end

      self.check_aln_len aln_len, rec

      self.update_col_arrays col_arys, rec

      col_arys
    end
  end

  def self.read_mask fname
    mask = Set.new
    ParseFasta::SeqFile.open(fname).each_record do |rec|
      rec.seq.each_char.with_index do |char, idx|
        mask << idx if char == "*"
      end
    end

    abort_if mask.length.zero?, "Length of mask was zero"

    mask
  end

  # helpers

  def self.idx_of_max_entropy_masked ents, mask
    idx_max_ent = -1
    max_ent = -1

    ents.each_with_index do |ent, idx|
      if mask.include?(idx) && ent > max_ent
        idx_max_ent = idx
      end
    end

    assert idx_max_ent >= 0

    idx_max_ent
  end

  def self.check_aln_len aln_len, rec
    abort_unless aln_len == rec.seq.length,
                 "Length of #{rec.header} was #{rec.seq.length}, " +
                 "expected #{aln_len}"
  end

  def self.entropy ary
    Shannon::entropy ary.join
  end

  def self.make_col_arrays aln_len
    Array.new(aln_len) { Array.new }
  end

  def self.update_col_arrays col_arys, rec
    rec.seq.each_char.with_index do |char, idx|
      # TODO check bounds of this idx
      col_arys[idx] << char.upcase
    end
  end

end
