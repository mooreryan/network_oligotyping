require "spec_helper"

RSpec.describe NetworkOligotyping do
  let(:test_dir) { File.join File.dirname(__FILE__), "test_files" }
  let(:aln_fname) { File.join test_dir, "aln.fa" }
  let(:aln_w_dif_lens) { File.join test_dir, "aln_w_dif_lengths.fa" }
  let(:col_arys) {
    [ %w[A T G],
      %w[C C C],
      %w[T T T],
      %w[G G G],
      %w[- G G] ]
  }

  it "has a version number" do
    expect(NetworkOligotyping::VERSION).not_to be nil
  end

  describe "::make_column_arrays" do
    it "makes column arrays for the aln file" do
      expect(NetworkOligotyping::make_column_arrays aln_fname).
        to eq col_arys
    end

    it "raises if aln file has not all same length seqs" do
      expect { NetworkOligotyping::make_column_arrays aln_w_dif_lens }.
        to raise_error SystemExit
    end

    it "raises some error if index is out of bounds"
  end

  describe "::index_of_max_entropy" do
    it "returns index of the column with the highest entropy" do
      expect(NetworkOligotyping::index_of_max_entropy col_arys).
        to be_zero
    end
  end
end
