#include <algorithm>
#include <bitset>
#include <chrono>
#include <iostream>
#include <random>

using Graph = std::vector<std::vector<int>>;

constexpr auto INF = std::numeric_limits<int>::max();
constexpr auto MAX_N = 32;

Graph generate_graph(int n) {
    Graph g(n, std::vector<int>(n));
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dist(1, 100);

    for (auto i = 0; i < n; i++) {
        for (auto j = i; j < n; j++) {
            if (i == j) {
                g[i][j] = 0;
            } else {
                auto w = dist(gen);
                g[i][j] = w;
                g[j][i] = w;
            }
        }
    }
    return g;
}

std::pair<int, std::vector<int>> tsp_brute_force(const Graph& g) {
    const auto n = g.size();
    if (n <= 1) return {0, {0}};

    std::vector<int> tour(n - 1);
    std::iota(tour.begin(), tour.end(), 1);

    auto min_cost = INF;
    std::vector<int> best_path;

    do {
        auto cur_cost = g[0][tour[0]];
        for (auto i = 0; i < tour.size() - 1; i++) {
            cur_cost += g[tour[i]][tour[i + 1]];
        }
        cur_cost += g[tour.back()][0];

        if (cur_cost < min_cost) {
            min_cost = cur_cost;
            best_path = tour;
        }
    } while (std::next_permutation(tour.begin(), tour.end()));

    best_path.insert(best_path.begin(), 0);
    best_path.push_back(0);

    return {min_cost, best_path};
}

std::pair<int, std::vector<int>> tsp_held_karp(const Graph& graph) {
    const auto n = graph.size();
    if (n == 0) return {0, {}};

    const auto num_masks = 1 << n;
    Graph dp(num_masks, std::vector<int>(n, INF));
    Graph parent(num_masks, std::vector<int>(n, -1));

    dp[1][0] = 0;

    for (auto mask_int = 1; mask_int < num_masks; ++mask_int) {
        std::bitset<MAX_N> visited(mask_int);

        for (auto v = 0; v < n; v++) {
            if (!visited.test(v) || dp[mask_int][v] == INF) {
                continue;
            }

            for (auto u = 0; u < n; u++) {
                if (v != u && !visited.test(u)) {
                    std::bitset<MAX_N> next = visited;
                    next.set(u);

                    auto next_mask = next.to_ulong();
                    auto new_cost = dp[mask_int][v] + graph[v][u];

                    if (new_cost < dp[next_mask][u]) {
                        dp[next_mask][u] = new_cost;
                        parent[next_mask][u] = v;
                    }
                }
            }
        }
    }

    auto min_tour_cost = INF;
    auto last = -1;
    auto final_mask_int = num_masks - 1;

    for (auto v = 1; v < n; ++v) {
        if (dp[final_mask_int][v] != INF) {
            auto current_cost = dp[final_mask_int][v] + graph[v][0];
            if (current_cost < min_tour_cost) {
                min_tour_cost = current_cost;
                last = v;
            }
        }
    }

    if (last == -1) return {INF, {}};

    std::vector<int> tour;
    tour.push_back(0);

    auto cur = last;
    std::bitset<MAX_N> current_set(final_mask_int);

    while (cur != 0) {
        tour.push_back(cur);
        auto prev_vertex = parent[current_set.to_ulong()][cur];
        current_set.reset(cur);
        cur = prev_vertex;
    }

    std::reverse(tour.begin(), tour.end());

    return {min_tour_cost, tour};
}

int main() {
    constexpr auto BRUTE_FORCE_MAX_N = 12;
    constexpr auto HELD_KARP_MAX_N = 22;

    for (auto n = 4; n <= HELD_KARP_MAX_N; n++) {
        std::cout << "n << " << n << "\n";

        Graph graph = generate_graph(n);

        if (n <= BRUTE_FORCE_MAX_N) {
            std::cout << "NAIVE\n";
            auto start = std::chrono::high_resolution_clock::now();
            auto [cost, tour] = tsp_brute_force(graph);
            auto end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::milli> duration = end - start;
            std::cout << "cost: " << cost << "\n";
            std::cout << "time: " << duration.count() << " ms\n\n";
        }

        std::cout << "BELLMAN-HELD-KARP\n";
        auto start = std::chrono::high_resolution_clock::now();
        auto [cost, tour] = tsp_held_karp(graph);
        auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double, std::milli> duration = end - start;
        std::cout << "cost: " << cost << "\n";
        std::cout << "time: " << duration.count() << " ms\n\n";
    }

    return 0;
}
