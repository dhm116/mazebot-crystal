require "./mazebot"

GridSize = 10

result = Mazebot.solve(GridSize)

answer = result[:answer]
directions = result[:directions]
maze = result[:maze]
solution = result[:solution]

directions_hash = directions.index_by { |tpl| {tpl[:node].data.x, tpl[:node].data.y} }

maze.print()

puts "Shortest path is #{directions.size} steps"
puts (directions
  .map { |tpl| tpl[:direction] }
  .join(" => ")
)

maze.print { |x,y,char|
  unless ["A", "B"].includes?(char)
    if directions_hash.has_key?({x,y})
      next directions_hash[{x,y}][:direction]
    end
  end
  next char
}

puts answer.to_json
