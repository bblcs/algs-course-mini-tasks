package topcount

func naive(n int, edges [][2]int) int {
	adj := make(map[int][]int)
	for _, edge := range edges {
		u, v := edge[0], edge[1]
		adj[u] = append(adj[u], v)
	}

	p := make([]int, n)
	for i := range n {
		p[i] = i
	}

	count := 0
	for {
		if istopo(p, adj) {
			count++
		}

		if !nextperm(p) {
			break
		}
	}

	return count
}

func istopo(p []int, adj map[int][]int) bool {
	pos := make(map[int]int, len(p))
	for i, v := range p {
		pos[v] = i
	}

	for u, neighbors := range adj {
		for _, v := range neighbors {
			if pos[u] > pos[v] {
				return false
			}
		}
	}

	return true
}

func nextperm(p []int) bool {
	k := -1
	for i := len(p) - 2; i >= 0; i-- {
		if p[i] < p[i+1] {
			k = i
			break
		}
	}

	if k == -1 {
		return false
	}

	l := -1
	for i := len(p) - 1; i > k; i-- {
		if p[k] < p[i] {
			l = i
			break
		}
	}

	p[k], p[l] = p[l], p[k]

	left, right := k+1, len(p)-1
	for left < right {
		p[left], p[right] = p[right], p[left]
		left++
		right--
	}

	return true
}
