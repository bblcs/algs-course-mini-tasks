// https://leetcode.com/problems/find-the-city-with-the-smallest-number-of-neighbors-at-a-threshold-distance/submissions/1798538459/

public class Solution {
    public int FindTheCity(int n, int[][] edges, int distanceThreshold) {
        var dist = new int[n, n];

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                dist[i, j] = (i == j) ? 0 : Int32.MaxValue;
            }
        }

        foreach (var edge in edges) {
            dist[edge[0], edge[1]] = dist[edge[1], edge[0]] = edge[2];
        }

        for (int k = 0; k < n; k++) {
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < n; j++) {
                    dist[i, j] = Math.Min(dist[i, j], dist[i, k] + dist[k, j]);
                }
            }
        }

        int resultCity = -1;
        int minReachableCount = n + 1;

        for (int i = 0; i < n; i++) {
            int currentReachableCount = 0;
            for (int j = 0; j < n; j++) {
                if (dist[i, j] <= distanceThreshold) {
                    currentReachableCount++;
                }
            }

            if (currentReachableCount <= minReachableCount) {
                minReachableCount = currentReachableCount;
                resultCity = i;
            }
        }

        return resultCity;
    }
}
