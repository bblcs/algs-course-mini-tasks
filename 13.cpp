#include <algorithm>
#include <vector>

template <typename T>
auto median(const std::vector<T>& v) {
    auto n = v.size();
    std::vector<T> t = v;

    if (n % 2 == 0) {
        std::nth_element(t.begin(), t.begin() + n / 2, t.end());
        std::nth_element(t.begin(), t.begin() + (n - 1) / 2, t.end());
        return (t[(n - 1) / 2] + t[n / 2]) / 2;
    } else {
        std::nth_element(t.begin(), t.begin() + n / 2, t.end());
        return t[n / 2];
    }
}
