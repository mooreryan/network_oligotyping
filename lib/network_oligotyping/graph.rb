module NetworkOligotyping
  class Graph
    # TODO make nodes return actually all nodes, and have a separate
    # thing for the name => node hash
    attr_accessor :nodes

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

    # Make a new Graph. Sets @nodes = {}
    def initialize
      @nodes = {}
    end

    def edges
      edges = []
      nodes.each do |name, node|
        node.connections.each do |connected_name|
          edges << [name, connected_name]
        end
      end

      edges
    end

    def prob_connection
      prob_of_connection nodes.count, edges.count
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

    # Prints out all connections in the graph.
    #
    # Since these are undirected graphs internally, it will print out
    # steph, klay and klay, steph to show that both paths are valid.
    def to_s
      ary = ["node1\tnode2"]

      self.each_node do |node|
        this_name = node.name

        node.connections.each do |other_name|
          ary << "#{this_name}\t#{other_name}"
        end
      end

      ary.join "\n"
    end
  end
end
