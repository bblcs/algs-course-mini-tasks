package topcount

import "testing"
import "fmt"

var benchcase = []struct {
	name  string
	n     int
	edges [][2]int
}{
	{
		name: "n=8",
		n:    8,
		edges: [][2]int{
			{0, 1}, {0, 2},
			{1, 3}, {1, 4},
			{2, 5},
			{3, 6}, {3, 7},
		},
	},
	{
		name: "n=10",
		n:    10,
		edges: [][2]int{
			{0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5},
			{1, 6},
			{3, 7}, {3, 8},
			{5, 9},
		},
	},
	{
		name: "n=11",
		n:    11,
		edges: [][2]int{
			{0, 1}, {0, 2}, {0, 3},
			{1, 4}, {1, 5},
			{2, 6}, {2, 7},
			{3, 8},
			{4, 9}, {4, 10},
		},
	},
}

func Benchmark(b *testing.B) {
	for _, bc := range benchcase {
		b.Run(fmt.Sprintf("[BENCH] poly/%s", bc.name), func(b *testing.B) {
			for b.Loop() {
				poly(bc.n, bc.edges)
			}
		})

		b.Run(fmt.Sprintf("[BENCH] naive/%s", bc.name), func(b *testing.B) {
			for b.Loop() {
				naive(bc.n, bc.edges)
			}
		})
	}
}
