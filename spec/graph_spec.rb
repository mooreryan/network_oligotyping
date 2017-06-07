require "spec_helper"

this_dir = File.dirname __FILE__

require_relative "#{this_dir}/../lib/network_oligotyping/node"

# def mock_node name, connections
#   node = double("Node")
#   allow(node).to receive(:name) { name }
#   allow(node).to receive(:connections) { Set.new connections }
#   allow(node).to receive(:add_connections) { |ary|
#     node.connections = node.connections.union Set.new ary
#   }
#   allow(node).to receive(:connections=) { |conns|
#     node.connections = conns
#   }

#   node
# end

def new_node name, connections
  NetworkOligotyping::Node.new name, connections
end

def graph_with_connections nodes
  graph = NetworkOligotyping::Graph.new

  nodes.each do |node|
    graph.add! node
  end

  graph
end

RSpec.describe NetworkOligotyping::Graph do
  let(:test_dir) { File.join File.dirname(__FILE__), "test_files" }
  let(:graph_fname) { File.join test_dir, "graph.txt" }

  let(:node) { new_node "apple", %w[pie good] }

  let(:node_apple) { new_node "apple", %w[pie] }
  let(:node_pie) { new_node "pie", %w[apple] }

  let(:graph) { NetworkOligotyping::Graph.new }

  let(:nodes) {
    [new_node("apple", ["pie", "good"]),
     new_node("pie", ["apple"]),
     new_node("good", ["apple"]),]
  }
  let(:edges) {
    [%w[apple pie],
     %w[apple good],
     %w[pie apple],
     %w[good apple],]
  }

  subject { graph }
  it { should respond_to :nodes }

  describe "::new" do
    it "sets @nodes to empty hash table" do
      expect(graph.nodes).to eq Hash.new
    end
  end

  describe "#add!" do
    it "adds a node if it does not yet exist in the graph" do
      graph.add! node
      node_ht = { "apple" => node }

      expect(graph.nodes).to eq node_ht
    end

    it "adds connections to an existing node" do
      graph.add! node

      node2 = new_node "apple", %w[pie tasty]
      graph.add! node2

      new_node = new_node "apple", %w[pie good tasty]
      nodes_ht = { "apple" => new_node }

      expect(graph.nodes).to eq nodes_ht
    end
  end

  describe "#edges" do
    it "returns the edges of the graph" do
      nodes.each do |node|
        graph.add! node
      end

      expect(graph.edges).to eq edges
    end
  end

  describe "#prob_connection" do
    it "returns the probability of connection between 2 nodes" do
      graph = graph_with_connections nodes

      # from graph_with_connections
      num_edges = 4
      num_nodes = 3
      actual = num_edges / num_nodes.times.map(&:itself).combination(2).count.to_f

      expect(graph.prob_connection).to eq actual
    end
  end

  describe "#each_node" do
    it "yields the nodes of the graph like each" do
      graph.add! node_apple
      graph.add! node_pie

      expect { |b| graph.each_node(&b) }.
        to yield_successive_args node_apple, node_pie
    end
  end

  describe "#==" do
    it "is true if graphs contain the same nodes" do
      g1 = NetworkOligotyping::Graph.new
      g2 = NetworkOligotyping::Graph.new

      g1.add! node
      g2.add! node

      expect(g1).to eq g2
    end

    it "is true if both graphs are empty" do
      g1 = NetworkOligotyping::Graph.new
      g2 = NetworkOligotyping::Graph.new

      expect(g1).to eq g2
    end

    it "is false otherwise" do
      g1 = NetworkOligotyping::Graph.new
      g2 = NetworkOligotyping::Graph.new

      g1.add! node

      expect(g1).not_to eq g2
    end
  end

  describe "::read_graph" do
    it "reads a graph from a text file" do
      graph = NetworkOligotyping::Graph.new

      graph.add! new_node "lebron", %w[kyrie love]
      graph.add! new_node "kyrie", %w[lebron love]
      graph.add! new_node "love", %w[lebron kyrie]

      graph.add! new_node "steph", %w[klay kd]
      graph.add! new_node "klay", %w[steph]
      graph.add! new_node "kd", %w[steph]

      expect(NetworkOligotyping::Graph.read_graph graph_fname).
        to eq graph
    end

    it "raises error if the file has bad format"
  end
end
