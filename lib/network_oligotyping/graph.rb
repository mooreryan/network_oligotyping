module NetworkOligotyping
  class Graph
    attr_accessor :nodes

    # Make a new Graph. Sets @nodes = {}
    def initialize
      @nodes = {}
    end

    # Add a node to the graph.
    #
    # If the node already exists in the graph, add the connections of
    # the new node to the existing node instead.
    #
    # @param node [Node] the node to add to the graph
    def add! node
      name = node.name

      if @nodes.has_key? name
        @nodes[name].add_connections node.connections
      else
        @nodes[name] = node
      end
    end

    # Yield each node in the graph
    #
    # @yieldparam node [Node] a node in the graph
    def each_node
      @nodes.each do |name, node|
        yield node
      end
    end

    def == graph
      self.nodes == graph.nodes
    end

    def self.read_graph fname
      graph = self.new
      File.open(fname, "rt").each_line.with_index do |line, idx|
        unless idx.zero?
          n1, n2, sample = line.chomp.split "\t"

          node1 = NetworkOligotyping::Node.new n1, [n2]
          node2 = NetworkOligotyping::Node.new n2, [n1]

          graph.add! node1
          graph.add! node2
        end
      end

      graph
    end
  end
end
