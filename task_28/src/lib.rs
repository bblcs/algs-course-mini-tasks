use std::collections::{HashMap, HashSet};

type Graph = HashMap<String, Vec<String>>;

fn parse_input(input: &str) -> Graph {
    let mut graph: Graph = HashMap::new();
    let mut all_nodes: HashSet<String> = HashSet::new();

    for line in input.lines() {
        let parts: Vec<&str> = line.splitn(2, ':').collect();
        if parts[0].trim().is_empty() {
            continue;
        }

        let caller = parts[0].trim().to_string();
        all_nodes.insert(caller.clone());

        let callees = if parts.len() == 2 {
            parts[1]
                .split(',')
                .map(|s| s.trim())
                .filter(|s| !s.is_empty())
                .map(|s| {
                    let callee = s.to_string();
                    all_nodes.insert(callee.clone());
                    callee
                })
                .collect()
        } else {
            Vec::new()
        };

        graph.insert(caller, callees);
    }
    graph
}

fn reverse_graph(graph: &Graph) -> Graph {
    let mut rev_graph: Graph = HashMap::new();

    for node in graph.keys() {
        rev_graph.entry(node.clone()).or_default();
    }

    for (caller, callees) in graph {
        for callee in callees {
            rev_graph
                .entry(callee.clone())
                .or_default()
                .push(caller.clone());
        }
    }
    rev_graph
}

fn dfs1(graph: &Graph, start_node: &str, visited: &mut HashSet<String>, order: &mut Vec<String>) {
    if !graph.contains_key(start_node) || visited.contains(start_node) {
        return;
    }

    // node : post_visit_flag
    let mut stack: Vec<(String, bool)> = vec![(start_node.to_string(), false)];

    while let Some((node, post_visit)) = stack.pop() {
        if post_visit {
            order.push(node);
            continue;
        }

        if visited.contains(&node) {
            continue;
        }

        visited.insert(node.clone());
        stack.push((node.clone(), true));

        if let Some(neighbors) = graph.get(&node) {
            for neighbor in neighbors {
                if !visited.contains(neighbor) {
                    stack.push((neighbor.clone(), false));
                }
            }
        }
    }
}

fn dfs2(
    graph: &Graph,
    start_node: &str,
    visited: &mut HashSet<String>,
    current_scc: &mut Vec<String>,
) {
    if !graph.contains_key(start_node) || visited.contains(start_node) {
        return;
    }

    let mut stack: Vec<String> = vec![start_node.to_string()];

    while let Some(node) = stack.pop() {
        if visited.contains(&node) {
            continue;
        }
        visited.insert(node.clone());
        current_scc.push(node.clone());

        if let Some(neighbors) = graph.get(&node) {
            for neighbor in neighbors {
                if !visited.contains(neighbor) {
                    stack.push(neighbor.clone());
                }
            }
        }
    }
}

fn kosaraju(graph: &Graph) -> Vec<Vec<String>> {
    if graph.is_empty() {
        return Vec::new();
    }

    let rev_graph = reverse_graph(graph);
    let mut visited: HashSet<String> = HashSet::new();
    let mut order: Vec<String> = Vec::new();

    let nodes: Vec<String> = graph.keys().cloned().collect();
    for node in &nodes {
        if !visited.contains(node) {
            dfs1(&rev_graph, node, &mut visited, &mut order);
        }
    }

    let mut sccs: Vec<Vec<String>> = Vec::new();
    visited.clear();

    for node in order.iter().rev() {
        if !visited.contains(node) {
            let mut current_scc: Vec<String> = Vec::new();
            dfs2(graph, node, &mut visited, &mut current_scc);
            if !current_scc.is_empty() {
                current_scc.sort();
                sccs.push(current_scc);
            }
        }
    }

    sccs
}

pub fn analyze_calls(input: &str) -> (Vec<String>, Vec<String>) {
    let graph = parse_input(input);
    if graph.is_empty() {
        return (Vec::new(), Vec::new());
    }

    let sccs = kosaraju(&graph);

    let largest_scc = sccs
        .iter()
        .map(|scc| scc.len())
        .max()
        .and_then(|max_len| {
            sccs.iter()
                .filter(|scc| scc.len() == max_len)
                .min()
                .cloned()
        })
        .unwrap_or_default();

    let mut recursive_functions: HashSet<String> = HashSet::new();
    for scc in &sccs {
        if scc.len() > 1 {
            for func in scc {
                recursive_functions.insert(func.clone());
            }
        } else if scc.len() == 1 {
            let func = &scc[0];
            if let Some(callees) = graph.get(func) {
                if callees.contains(func) {
                    recursive_functions.insert(func.clone());
                }
            }
        }
    }

    let mut sorted_recursive: Vec<String> = recursive_functions.into_iter().collect();
    sorted_recursive.sort();

    (largest_scc, sorted_recursive)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_example() {
        let input = "
        foo: bar, baz, qux
        bar: baz, foo, bar
        qux: qux
        baz:
        ";
        let (largest_scc, recursive) = analyze_calls(input);
        assert_eq!(largest_scc, vec!["bar", "foo"]);
        assert_eq!(recursive, vec!["bar", "foo", "qux"]);
    }

    #[test]
    fn test_single_dummy() {
        let input = "a:";
        let (largest_scc, recursive) = analyze_calls(input);
        assert_eq!(largest_scc, vec!["a"]);
        assert!(recursive.is_empty());
    }

    #[test]
    fn test_dummies() {
        let input = "
        a:
        b:
        c:
        ";
        let (largest_scc, recursive) = analyze_calls(input);
        assert_eq!(largest_scc, vec!["a"]);
        assert!(recursive.is_empty());
    }

    #[test]
    fn test_rec_one() {
        let input = "a: a";
        let (largest_scc, recursive) = analyze_calls(input);
        assert_eq!(largest_scc, vec!["a"]);
        assert_eq!(recursive, vec!["a"]);
    }

    #[test]
    fn test_rec_two() {
        let input = "
        a: b
        b: a
        ";
        let (largest_scc, recursive) = analyze_calls(input);
        // SCC: [a, b]
        assert_eq!(largest_scc, vec!["a", "b"]);
        // Recursive: a, b (part of SCC > 1)
        assert_eq!(recursive, vec!["a", "b"]);
    }

    #[test]
    fn test_multiple_sccs() {
        let input = "
        a: b
        b: a
        c: d, e
        d: c
        e: f
        f: e, g
        g: g
        h: a, c 
        ";
        let (largest_scc, recursive) = analyze_calls(input);
        assert_eq!(largest_scc, vec!["a", "b"]);
        assert_eq!(recursive, vec!["a", "b", "c", "d", "e", "f", "g"]);
    }

    #[test]
    fn test_no_rec() {
        let input = "
        a: b, c
        b: d
        c: d
        d:
        ";
        let (largest_scc, recursive) = analyze_calls(input);
        assert_eq!(largest_scc, vec!["a"]);
        assert!(recursive.is_empty());
    }

    #[test]
    fn test_rec_disconnected() {
        let input = "
         a: b
         b: a
         x: y
         y: z, x
         z: y
         ";
        let (largest_scc, recursive) = analyze_calls(input);
        assert_eq!(largest_scc, vec!["x", "y", "z"]);
        assert_eq!(recursive, vec!["a", "b", "x", "y", "z"]);
    }
}
