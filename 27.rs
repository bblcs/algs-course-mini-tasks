// https://leetcode.com/problems/sort-items-by-groups-respecting-dependencies/submissions/1617711344

use std::collections::{HashMap, HashSet};

impl Solution {
    pub fn sort_items(n: i32, m: i32, group: Vec<i32>, before_items: Vec<Vec<i32>>) -> Vec<i32> {
        let n = n as usize;
        let mut m = m as usize;
        let mut group = group;
        for i in 0..n {
            if group[i] == -1 {
                group[i] = m as i32;
                m += 1;
            }
        }

        let mut item_adj = vec![vec![]; n];
        let mut item_indegree = vec![0; n];
        let mut group_adj = vec![HashSet::new(); m];
        let mut group_indegree = vec![0; m];

        for i in 0..n {
            for &prev in &before_items[i] {
                item_adj[prev as usize].push(i);
                item_indegree[i] += 1;
                let prev_group = group[prev as usize] as usize;
                let current_group = group[i] as usize;
                if prev_group != current_group && group_adj[prev_group].insert(current_group) {
                    group_indegree[current_group] += 1;
                }
            }
        }

        let item_order = tsort(&item_adj, &mut item_indegree);
        if item_order.len() != n {
            return vec![];
        }
        let group_order = tsort(
            &group_adj
                .iter()
                .map(|s| s.iter().cloned().collect())
                .collect(),
            &mut group_indegree,
        );
        if group_order.len() != m {
            return vec![];
        }

        let mut items_in_group: Vec<Vec<i32>> = vec![vec![]; m];
        for &item in &item_order {
            items_in_group[group[item as usize] as usize].push(item);
        }

        group_order
            .into_iter()
            .flat_map(|g| items_in_group[g as usize].clone())
            .collect()
    }
}
fn tsort(adj: &Vec<Vec<usize>>, indegree: &mut Vec<i32>) -> Vec<i32> {
    let mut q: Vec<usize> = (0..indegree.len()).filter(|&i| indegree[i] == 0).collect();
    let mut order = vec![];
    let mut head = 0;
    while head < q.len() {
        let u = q[head];
        head += 1;
        order.push(u as i32);
        for &v in &adj[u] {
            indegree[v] -= 1;
            if indegree[v] == 0 {
                q.push(v);
            }
        }
    }
    order
}
