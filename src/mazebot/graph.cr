module Mazebot
  class Graph
    getter nodes = Array(Mazebot::Node).new

    def add_node(data : Mazebot::NodeData)
      @nodes << Mazebot::Node.new(data)
      @nodes[-1]
    end

    def self.from(maze : Mazebot::Maze) : self
      graph = self.new
      # Create and add nodes to graph
      maze.map.each_with_index {|row, y|
        row.each_with_index {|char, x|
          node = graph.add_node(Mazebot::NodeData.new(x: x, y: y, character: char))
          maze.start = node if char === "A"
          maze.finish = node if char === "B"
        }
      }

      node_index = graph.nodes.index_by{ |node| {x: node.data.x, y: node.data.y} }
      # Create and add Edges to anything that isn't connected to an "X" space
      graph.nodes.reject { |node|
        node.data.character === "X"
      }
      .each do |node|
        x, y = node.data.x, node.data.y
        [
          {x: x - 1, y: y},
          {x: x + 1, y: y},
          {x: x, y: y - 1},
          {x: x, y: y + 1},
        ]
        .select { |coord|
          node_index.has_key?(coord)
         }
        .map { |coord| node_index[coord] }
        .reject { |neighbor|
          neighbor.data.character === "X"
        }
        .each { |neighbor|
          to_x, to_y = neighbor.data.x, neighbor.data.y
          distance = ((x - to_x).abs + (y - to_y).abs).to_i
          node.connect_to(neighbor, distance)
        }
      end

      graph
    end
  end
end
