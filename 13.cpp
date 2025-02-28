#include <algorithm>
#include <vector>

template <typename T> using Wells = std::vector<std::pair<T, T>>;

template <typename T> auto sol(const Wells<T> &wells) {
  auto compare_by_y = [](const auto &a, const auto &b) {
    return a.second < b.second;
  };

  auto min_y =
      (*std::min_element(wells.begin(), wells.end(), compare_by_y)).second;
  auto max_y =
      (*std::max_element(wells.begin(), wells.end(), compare_by_y)).second;

  return (min_y + max_y) / 2;
}
