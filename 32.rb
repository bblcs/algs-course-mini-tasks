# https://leetcode.com/problems/redundant-connection/submissions/1776622323/

class UnionFind
  def initialize(n)
    @parent = (0..n).to_a
    @rank = Array.new(n + 1, 0)
  end

  def find(i)
    if @parent[i] != i
      @parent[i] = find(@parent[i])
    end
    @parent[i]
  end

  def union(i, j)
    repri = find(i)
    reprj = find(j)

    return false if repri == reprj

    if @rank[repri] < @rank[reprj]
      @parent[repri] = reprj
    elsif @rank[repri] > @rank[reprj]
      @parent[reprj] = repri
    else
      @parent[reprj] = repri
      @rank[repri] += 1
    end

    true
  end
end


def find_redundant_connection(edges)
  uf = UnionFind.new(edges.length)

  edges.each do |u, v|
    if !uf.union(u, v)
      return [u, v]
    end
  end
end

