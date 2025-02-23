#include <algorithm>
#include <vector>

using namespace std;

using It = vector<int>::iterator;

static void merge(It l_start, It l_end, It r_start, It r_end, It tbuf) {
  while (l_start != l_end && r_start != r_end)
    iter_swap(tbuf++, (*l_start < *r_start) ? l_start++ : r_start++);
  while (l_start != l_end)
    iter_swap(l_start++, tbuf++);
  while (r_start != r_end)
    iter_swap(r_start++, tbuf++);
}

static void merge_sort(It start, It end);

static void merge_sort_internal(It start, It end, It tbuf) {
  if (start == end)
    return;

  if (next(start) == end) {
    iter_swap(tbuf, start);
    return;
  }

  It mid = start + distance(start, end) / 2;

  merge_sort(start, mid);
  merge_sort(mid, end);

  merge(start, mid, mid, end, tbuf);
}

static void merge_sort(It start, It end) {
  if (start == end || next(start) == end)
    return;

  It mid = start + distance(start, end) / 2;
  It tbuf = end - distance(start, mid);

  merge_sort_internal(start, mid, tbuf);

  while (distance(start, tbuf) > 1) {
    mid = tbuf;
    tbuf = start + (distance(start, mid) + 1) / 2;

    merge_sort_internal(tbuf, mid, start);
    merge(start, start + (distance(tbuf, mid)), mid, end, tbuf);
  }

  if (distance(start, tbuf) == 1) {
    for (It it = start; next(it) != end && *it > *next(it); it++)
      iter_swap(it, next(it));
  }
}

class Solution {
public:
  vector<int> sortArray(vector<int> &nums) {
    merge_sort(nums.begin(), nums.end());
    return nums;
  }
};
