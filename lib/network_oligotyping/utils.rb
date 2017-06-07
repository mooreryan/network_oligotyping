module NetworkOligotyping
  module Utils
    def factorial n
      (1..n).reduce(1, :*)
    end

    def combination num_things, group_size
      factorial(num_things) / (factorial(group_size) * factorial(num_things - group_size))
    end

    def prob_of_expected_edges expected_edges, num_nodes, prob_of_connection
      (combination(num_nodes-1, expected_edges) * prob_of_connection ** expected_edges) * (1 - prob_of_connection) ** (num_nodes - 1 - expected_edges)
    end

    def prob_greater_than_expected_edges expected_edges, num_nodes, prob_of_connection
      1 - (0..expected_edges-1).reduce(0) { |sum, n_edges| sum += prob_of_expected_edges(n_edges, num_nodes, prob_of_connection) }
    end

    # TODO i think this is just a bit off
    def is_hub? alpha, expected_edges, num_nodes, prob_of_connection
      prob_greater_than_expected_edges(expected_edges, num_nodes, prob_of_connection) < alpha
    end

    # TODO is this prob of undirected connection or directed
    def prob_of_connection num_edges, num_nodes
      num_edges / combination(num_nodes, 2).to_f
    end
  end
end
