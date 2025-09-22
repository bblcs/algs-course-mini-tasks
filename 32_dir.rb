# https://leetcode.com/problems/redundant-connection-ii/submissions/1779069764/

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

def find_redundant_directed_connection(edges)
  n = edges.length
  parent = Array.new(n + 1, 0)
  cand1 = nil
  cand2 = nil

  edges.each do |u, v|
    if parent[v] != 0
      cand1 = [parent[v], v]
      cand2 = [u, v]
      break
    end
    parent[v] = u
  end

  uf = UnionFind.new(n)

  if cand1.nil?
    edges.each do |u, v|
      return [u, v] unless uf.union(u, v)
    end
  else
    edges.each do |u, v|
      next if u == cand2[0] && v == cand2[1]

      unless uf.union(u, v)
        return cand1
      end
    end
  
    return cand2
  end
end
