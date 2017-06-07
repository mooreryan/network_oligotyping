require "abort_if"
require "parse_fasta"
require "shannon"
require "set"

include AbortIf
include AbortIf::Assert

require "network_oligotyping/graph"
require "network_oligotyping/node"
require "network_oligotyping/utils"
require "network_oligotyping/version"

include NetworkOligotyping::Utils


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

  # Indexes the seqs in the alignment by their alignment order.
  #
  # @param fname [String] name of alignment file
  #
  # @return [Hash] seq => order index
  def self.make_seq_to_idx fname
    seq2idx = {}
    idx = -1

    ParseFasta::SeqFile.open(fname).each_record do |rec|
      idx += 1

      seq2idx[rec.header] = idx
    end

    seq2idx
  end

  def self.otu_indices otu, otu2seqs, seq2idx
    seqs = otu2seqs[otu]
    assert seqs, "#{otu} missing from otu2seqs"

    indices = seqs.map { |seq| seq2idx[seq] }
    assert indices.none?(&:nil?), "A seq was missing from seq2idx"

    Set.new indices
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

  def self.read_otu_calls fname
    otu2seqs = {}

    File.open(fname, "rt").each_line do |line|
      unless line.start_with? "#"
        seq, sample, otu, *rest = line.chomp.split "\t"

        if otu2seqs.has_key? otu
          otu2seqs[otu] << seq
        else
          otu2seqs[otu] = Set.new [seq]
        end
      end
    end

    otu2seqs
  end

  # Select certain columns of the alignment given by indices.
  #
  # @param col_arys [Array<Array<String>>] arrays of columns of
  #   alignment
  #
  # @param indices [Array<Fixnum>] indices of the columns you want
  #   to keep
  #
  # @return col_arys but with only the columns listed in indices
  def self.subset_col_arys col_arys, indices
    self.subset_by_indices col_arys, indices
  end

  # Select certain sequences by index
  def self.subset_col_arys_by_seq_idx col_arys, seq_indices
    seq_arys = col_arys.transpose

    self.subset_by_indices(seq_arys, seq_indices).transpose
  end

  ######################################################################
  # helpers
  #########

  def self.idx_of_max_entropy_masked ents, mask
    idx_max_ent = -1
    max_ent = -1

    ents.each_with_index do |ent, idx|
      if mask.include?(idx) && ent > max_ent
        idx_max_ent = idx
        max_ent = ent
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

  def self.subset_by_indices arrays, indices
    arrays.select.with_index do |ary, idx|
      indices.include? idx
    end
  end

  def self.update_col_arrays col_arys, rec
    rec.seq.each_char.with_index do |char, idx|
      # TODO check bounds of this idx
      col_arys[idx] << char.upcase
    end
  end

  #########
  # helpers
  ######################################################################
end
