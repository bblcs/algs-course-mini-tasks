package topcount

import (
	"testing"
)

func Test(t *testing.T) {
	testCases := []struct {
		name  string
		n     int
		edges [][2]int
	}{
		{
			name:  "empty",
			n:     0,
			edges: [][2]int{},
		},
		{
			name:  "single",
			n:     1,
			edges: [][2]int{},
		},
		{
			name:  "two disconnected",
			n:     2,
			edges: [][2]int{},
		},
		{
			name:  "two one way",
			n:     2,
			edges: [][2]int{{0, 1}},
		},
		{
			name:  "chain",
			n:     4,
			edges: [][2]int{{0, 1}, {1, 2}, {2, 3}},
		},
		{
			name:  "star",
			n:     4,
			edges: [][2]int{{0, 1}, {0, 2}, {0, 3}},
		},
		{
			name:  "forest",
			n:     5,
			edges: [][2]int{{0, 1}, {3, 4}},
		},
		{
			name: "binary",
			n:    7,
			edges: [][2]int{
				{0, 1}, {0, 2},
				{1, 3}, {1, 4},
				{2, 5}, {2, 6},
			},
		},
		{
			name: "assymetric",
			n:    8,
			edges: [][2]int{
				{0, 1}, {0, 2},
				{1, 3}, {1, 4},
				{2, 5},
				{3, 6}, {3, 7},
			},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			expected := naive(tc.n, tc.edges)
			actual := poly(tc.n, tc.edges)

			if expected != actual {
				t.Errorf("mismatch:\n\tactual:  %d\n\texpected: %d", actual, expected)
			}
		})
	}
}
