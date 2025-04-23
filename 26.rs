// https://leetcode.com/problems/is-graph-bipartite/submissions/1615499004

#[derive(Clone, Copy, PartialEq, Eq)]
enum Color {
    None,
    Green,
    Yellow,
}

impl Color {
    fn opposite(&self) -> Self {
        match self {
            Color::Green => Color::Yellow,
            Color::Yellow => Color::Green,
            Color::None => Color::None,
        }
    }
}

impl Solution {
    pub fn is_bipartite(graph: Vec<Vec<i32>>) -> bool {
        let n = graph.len();
        if n == 0 {
            return true;
        }

        let mut colors: Vec<Color> = vec![Color::None; n];

        for i in 0..n {
            if colors[i] == Color::None {
                if !Self::try_color(i, Color::Green, &mut colors, &graph) {
                    return false;
                }
            }
        }
        true
    }

    fn try_color(
        node_idx: usize,
        target_color: Color,
        colors: &mut Vec<Color>,
        graph: &Vec<Vec<i32>>,
    ) -> bool {
        colors[node_idx] = target_color;

        for &neighbor_val in &graph[node_idx] {
            let neighbor_idx = neighbor_val as usize;
            match colors[neighbor_idx] {
                Color::None => {
                    let opposite_color = target_color.opposite();
                    if !Self::try_color(neighbor_idx, opposite_color, colors, graph) {
                        return false;
                    }
                }
                neighbor_color => {
                    if neighbor_color == target_color {
                        return false;
                    }
                }
            }
        }
        true
    }
}
