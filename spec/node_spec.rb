require "spec_helper"

RSpec.describe NetworkOligotyping::Node do
  let(:name) { "apple" }
  let(:connections) { %w[pie good] }
  let(:node) {
    NetworkOligotyping::Node.new name, connections
  }

  subject { node }
  it { should respond_to :name }
  it { should respond_to :connections }

  describe "::new" do
    it "sets @name" do
      expect(node.name).to eq name
    end

    it "sets @connections" do
      expect(node.connections).to eq Set.new connections
    end
  end

  describe "#==" do
    it "returns true if nodes have same name and connections" do
      expect(node).
        to eq NetworkOligotyping::Node.new name, connections
    end

    it "returns false otherwise" do
      expect(node).
        not_to eq NetworkOligotyping::Node.new(name, %w[yummy])
    end
  end

  describe "#add_connections" do
    it "adds the array of names to the existing connections" do
      names = %w[fruit gross]
      node.add_connections names

      expect(node.connections).to eq Set.new %w[pie good fruit gross]
    end
  end
end
