require "set"

module NetworkOligotyping
  class Node
    attr_accessor :name, :connections

    # Make a new Node
    #
    # @param name [String] name of the node
    #
    # @param connections [Array<String>] array of names of connected
    #   nodes
    #
    # @return a new node
    def initialize name, connections
      @name = name
      @connections = Set.new connections
    end

    def == node
      self.name == node.name && self.connections == node.connections
    end

    # Adds in the connections ignoring duplicates
    #
    # @param node_names [Array<String>] an array of node names
    #
    # @note Modifies state
    def add_connections node_names
      @connections = @connections.union node_names
    end
  end
end
