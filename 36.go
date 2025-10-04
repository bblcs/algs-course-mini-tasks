// https://leetcode.com/problems/regular-expression-matching/submissions/1790740666/

func isMatch(s string, p string) bool {
	m, n := len(s), len(p)
	t := make([][]bool, m+1)
	for i := range t {
		t[i] = make([]bool, n+1)
	}

	t[0][0] = true

	for j := 1; j <= n; j++ {
		if p[j-1] == '*' {
			t[0][j] = t[0][j-2]
		}
	}

	for i := 1; i <= m; i++ {
		for j := 1; j <= n; j++ {
			if p[j-1] != '*' {
				if t[i-1][j-1] && (s[i-1] == p[j-1] || p[j-1] == '.') {
					t[i][j] = true
				}
			} else {
				zero := t[i][j-2]

				nonzero := false
				if s[i-1] == p[j-2] || p[j-2] == '.' {
					nonzero = t[i-1][j]
				}

				t[i][j] = zero || nonzero
			}
		}
	}

	return t[m][n]
}
