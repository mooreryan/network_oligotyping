require "spec_helper"

RSpec.describe NetworkOligotyping do

  # generic non SystemExit errror
  let(:non_exit_error) { AssertionFailureError }

  let(:test_dir) { File.join File.dirname(__FILE__), "test_files" }
  let(:aln_fname) { File.join test_dir, "aln.fa" }
  let(:mask_fname) { File.join test_dir, "mask.fa" }
  let(:otu_calls_fname) { File.join test_dir, "otu_calls.txt" }
  let(:aln_w_dif_lens) { File.join test_dir, "aln_w_dif_lengths.fa" }

  let(:col_arys) {
    [ %w[A T G],
      %w[C C C],
      %w[T T T],
      %w[G G G],
      %w[- G G] ]
  }

  let(:seq2idx) {
    { "seq 1" => 0,
      "seq 2" => 1,
      "seq 3" => 2 }
  }

  let(:otu2seqs) {
    { "otu a" => Set.new(["seq 1", "seq 3"]),
      "otu b" => Set.new(["seq 2"]) }
  }

  it "has a version number" do
    expect(NetworkOligotyping::VERSION).not_to be nil
  end

  describe "::index_of_max_entropy" do
    it "returns index of the column with the highest entropy" do
      expect(NetworkOligotyping::index_of_max_entropy col_arys).
        to be_zero
    end

    it "ignores positions not in the mask" do
      mask = Set.new [1, 2, 3, 4]
      expect(NetworkOligotyping::index_of_max_entropy col_arys, mask).
        to eq 4
    end

    it "works the same as no mask if mask is every posn" do
      mask = Set.new [0, 1, 2, 3, 4]
      expect(NetworkOligotyping::index_of_max_entropy col_arys, mask).
        to eq 0
    end
  end

  # describe "::index_of_max_entropy_given_otu" do
  #   it "works" do
  #     mask = Set.new [0, 1]
  #     otu = "otu a"
  #     expect(NetworkOligotyping::index_of_max_entropy_given_otu mask,
  #                                                               otu,
  #                                                               otu2seqs,
  #                                                               seq2idx,
  #                                                               col_arys).
  #       to eq 0
  #   end
  # end

  describe "::make_column_arrays" do
    it "makes column arrays for the aln file" do
      expect(NetworkOligotyping::make_column_arrays aln_fname).
        to eq col_arys
    end

    it "raises error if aln file has not all same length seqs" do
      expect { NetworkOligotyping::make_column_arrays aln_w_dif_lens }.
        to raise_error SystemExit
    end

    it "raises some error if index is out of bounds"
  end

  describe "::make_seq_to_idx" do
    it "reads the aln and returns hash table with seq => idx" do
      expect(NetworkOligotyping::make_seq_to_idx aln_fname).
        to eq seq2idx
    end
  end

  describe "::otu_indices" do
    it "returns set of indices for the otu" do
      otu = "otu a"

      expect(NetworkOligotyping::otu_indices otu, otu2seqs, seq2idx).
        to eq Set.new([0, 2])
    end

    it "raises error if otu is not in otu2seqs" do
      otu = "arstoien"

      expect { NetworkOligotyping::otu_indices otu, otu2seqs, seq2idx }.
        to raise_error non_exit_error
    end

    it "raises error if seq is not in seq2idx" do
      otu = "otu a"
      seq2idx.delete "seq 1"

      expect { NetworkOligotyping::otu_indices otu, otu2seqs, seq2idx }.
        to raise_error non_exit_error
    end
  end

  describe "::read_mask" do
    it "reads the entropy file returning a set of posns" do
      mask = Set.new [0, 1, 2, 4]
      expect(NetworkOligotyping::read_mask mask_fname).to eq mask
    end

    it "raises error if no mask positions were found" do
      expect { NetworkOligotyping::read_mask aln_fname }.
        to raise_error SystemExit
    end
  end

  describe "::read_otu_calls" do
    it "reads the otu calls into a hash table" do
      expect(NetworkOligotyping::read_otu_calls otu_calls_fname).
        to eq otu2seqs
    end

    it "raises error if seq is duplicated"
  end

  describe "::subset_col_arys" do
    it "selects col arrays given a enumerable of indices" do
      indices = [1, 3]

      expect(NetworkOligotyping::subset_col_arys col_arys, indices).
        to eq [col_arys[1], col_arys[3]]
    end

    it "handles out of bound indices"
  end

  describe "::subset_col_arys_by_seq_idx" do
    it "returns col arrays but only for sequences given by indices" do
      indices = [0, 2]
      subset = [ %w[A G],
                 %w[C C],
                 %w[T T],
                 %w[G G],
                 %w[- G] ]

      expect(NetworkOligotyping::subset_col_arys_by_seq_idx col_arys,
                                                            indices).
        to eq subset
    end

    it "handles out of bound indices"
  end
end
