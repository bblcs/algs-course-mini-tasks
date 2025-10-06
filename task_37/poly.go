package topcount

var fact []int

func prefact(n int) {
	fact = make([]int, n+1)
	fact[0] = 1
	for i := 1; i <= n; i++ {
		fact[i] = fact[i-1] * i
	}
}

func combinations(n, k int) int {
	if k < 0 || k > n {
		return 0
	}
	return fact[n] / (fact[k] * fact[n-k])
}

func poly(n int, edges [][2]int) int {
	if n <= 1 {
		return 1
	}

	adj := make([][]int, n)
	indegree := make([]int, n)
	for _, edge := range edges {
		u, v := edge[0], edge[1]
		adj[u] = append(adj[u], v)
		indegree[v]++
	}

	prefact(n)

	dp := make([]int, n)
	subtree_size := make([]int, n)

	var dfs func(u int)
	dfs = func(u int) {
		if subtree_size[u] != 0 {
			return
		}

		subtree_size[u] = 1
		dp[u] = 1

		for _, v := range adj[u] {
			dfs(v)
			total_nodes_to_combine := (subtree_size[u] - 1) + subtree_size[v]
			ways_to_combine := combinations(total_nodes_to_combine, subtree_size[v])
			dp[u] *= dp[v] * ways_to_combine
			subtree_size[u] += subtree_size[v]
		}
	}

	var roots []int
	for i := range n {
		if indegree[i] == 0 {
			roots = append(roots, i)
			dfs(i)
		}
	}

	var c int = 1
	tot_size := 0
	for _, root := range roots {
		ways_to_combine := combinations(tot_size+subtree_size[root], subtree_size[root])
		c *= dp[root] * ways_to_combine
		tot_size += subtree_size[root]
	}

	return c
}
