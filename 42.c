// https://leetcode.com/problems/create-sorted-array-through-instructions/submissions/1819844108/

#include <string.h>

#define SIZE 100001
#define MOD 1000000007

typedef unsigned int unt;

unt tree[SIZE];

unt f(unt x) {
    return x & (x + 1);
}

unt g(unt x) {
    return x | (x + 1);
}

void inc(unt pos, unt val) {
    for (unt i = pos; i < SIZE; i = g(i)) {
        tree[i] += val;
    }
}

unt get_prefix_sum(unt pos) {
    unt ans = 0;
    for (int current_pos = pos; current_pos >= 0;
         current_pos = f(current_pos) - 1) {
        ans += tree[current_pos];
    }
    return ans;
}

int createSortedArray(int* instructions, int instructionsSize) {
    memset(tree, 0, sizeof(tree));

    long long total = 0;

    for (unt i = 0; i < instructionsSize; i++) {
        unt x = instructions[i];
        unt count_less = get_prefix_sum(x - 1);
        unt count_greater = i - get_prefix_sum(x);
        unt cost = (count_less < count_greater) ? count_less : count_greater;
        total += cost;
        inc(x, 1);
    }

    return (unt)(total) % MOD;
}
