# A very simple priority key implementation to help our Dijkstra algorithm.
class PriorityQueue(K,V)
  def initialize
    @queue = Array({K,V}).new
  end

  def any?
    @queue.any?
  end

  def insert(key : K, value : V)
    if index = @queue.index({key, value})
      @queue[index] = {key, value}
    else
      @queue << {key, value}
    end
    order_queue
  end

  def remove_min
    @queue.shift.first
  end

  private def order_queue
    @queue.sort_by {|_key, value| value }
  end
end
