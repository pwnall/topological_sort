require 'set'

# Performs a topological sort on a graph.
#
# Args:
#   nodes:: Enumerable of all the nodes in the graph, or at least a subset of
#           nodes that the entire graph is reachable from
#
# Requires a block that takes a node as an argument and returns a hash with the
# following keys:
#   :id:: a unique ID for the node; this makes the algorithm work with graphs
#         that have multiple objects representing the same node; if the :id key
#         is not set, the node object is used as its own ID
#   :next:: array of nodes that are reachable by direct edges from the given
#           node; if the :next key is not set, the given node is assumed to be a
#           sink  
#
# Returns the graph's nodes, in topological order. This means that if node A is
# before node B, there is no path from A to B in the graph.
#
# Raises an ArgumentError if the graph is cyclic. 
def topological_sort(root_nodes)
  nodes = []

  # Topological-sorting DFS.
  visited = Set.new  # IDs for the visited nodes.
  active = Set.new  # IDs for the nodes that are currently on the stack.
  stack = []  # DFS stack state. Entries are [node, id, child_number, children].
  root_nodes.each do |root_node|
    node_data = yield root_node
    node_id = node_data.has_key?(:id) ? node_data[:id] : root_node
    next if visited.include? node_id
    
    visited << node_id
    stack << [root_node, node_id, -1, node_data[:next] || []]
    active << node_id
    
    until stack.empty?
      stack.last[2] += 1
      node, node_id, child_number, children = *stack.last
      
      if child_node = children[child_number]
        node_data = yield child_node
        node_id = node_data.has_key?(:id) ? node_data[:id] : child_node
        if active.include? node_id
          raise ArgumentError, 'Cyclical graph'
        end
        unless visited.include? node_id
          visited << node_id
          active << node_id
          stack << [child_node, node_id, -1, node_data[:next] || []]
        end
      else
        nodes << node
        active.delete stack.last[1]
        stack.pop
      end
    end
  end
      
  nodes  
end
