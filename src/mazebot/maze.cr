require "json"

module Mazebot
  class ExampleSolution
    JSON.mapping(
      directions: String
    )
  end

  class SolutionResponse
    JSON.mapping(
      elapsed: Int32?,
      local_timing: Hash(String, Float64)?,
      message: String?,
      nextMaze: String?,
      result: String?,
      size: Int32?,
      shortestSolutionLength: Int32?,
      yourSolutionLength: Int32?
    )
  end

  class Maze
    property start : (Mazebot::Node)?
    property finish : (Mazebot::Node)?

    JSON.mapping(
      name: String,
      mazePath: String,
      startingPosition: Array(Int32),
      endingPosition: Array(Int32),
      message: String,
      # exampleSolution: {type: ExampleSolution, nillable: true},
      map: Array(Array(String))
    )

    def print
      self.print { |x, y, char| char }
    end

    def print(&block : Int32, Int32, String -> String)
      just_spacing = Math.log10(@map.size).to_i + 2
      rows = self.stringify_rows(&block)
      rows = rows.map_with_index do |row, y|
        l_row_number = "#{y}".ljust(just_spacing)
        r_row_number = "#{y}".rjust(just_spacing)
        "|#{l_row_number}|#{row}|#{r_row_number}|"
      end

      width = rows.max_of {|row| row.size}
      # Top Border
      puts "".rjust(width, '_')

      rows.each {|row|
        puts row
        # puts "|".ljust(width - 1, '-') + "|"
      }

      # Bottom Border
      puts "".rjust(width, '-')
      start_s = "Start=[#{@start.as(Mazebot::Node).to_s}]"
      end_s = "End=[#{@finish.as(Mazebot::Node).to_s}]"
      puts start_s.rjust(start_s.size + 4)
      puts end_s.rjust(end_s.size + 4)
      puts "".rjust(width, '-')
    end

    def size
      @map.size
    end

    def stringify_rows(&block : Int32, Int32, String -> String) : Array(String)
      max_cell_width = (@map.size**2).to_s().size
      @map.map_with_index do |row, y|
        cells = row.map_with_index do |character, x|
          block.call(x, y, character)
        end
        # cells.map! {|c| c.rjust(max_cell_width, ' ')}
        cells.join("")
      end
    end
  end
end
