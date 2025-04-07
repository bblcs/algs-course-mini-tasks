#include <algorithm>
#include <vector>

template <typename RandomIt, typename Compare>
RandomIt median_of_three(RandomIt first, RandomIt mid, RandomIt lastdec, Compare comp) {
    if (comp(*mid, *first)) {
        std::iter_swap(mid, first);
    }
    if (comp(*lastdec, *mid)) {
        std::iter_swap(lastdec, mid);
        if (comp(*mid, *first)) {
            std::iter_swap(mid, first);
        }
    }
    return mid;
}

template <typename RandomIt, typename Compare>
std::pair<RandomIt, RandomIt> partition_3way(RandomIt first, RandomIt last, RandomIt pivot_it,
                                             Compare comp) {
    using Val = typename std::iterator_traits<RandomIt>::value_type;
    Val pivot_val = *pivot_it;
    std::iter_swap(first, pivot_it);

    RandomIt lt = first;
    RandomIt gt = last;
    RandomIt i = first + 1;

    while (i < gt) {
        if (comp(*i, pivot_val)) {
            std::iter_swap(lt, i);
            ++lt;
            ++i;
        } else if (comp(pivot_val, *i)) {
            --gt;
            std::iter_swap(i, gt);
        } else {
            ++i;
        }
    }

    return {lt, gt};
}

template <typename RandomIt, typename Compare>
void nth_element(RandomIt first, RandomIt nth, RandomIt last, Compare comp) {
    for (;;) {
        auto dist = std::distance(first, last);
        if (dist <= 1) {
            return;
        }

        RandomIt mid = first + dist / 2;
        RandomIt pivot_it = median_of_three(first, mid, last - 1, comp);

        auto pivot_range = partition_3way(first, last, pivot_it, comp);

        if (nth >= pivot_range.first && nth < pivot_range.second) {
            return;
        } else if (nth < pivot_range.first) {
            last = pivot_range.first;
        } else {
            first = pivot_range.second;
        }
    }
}

template <typename T>
auto median(const std::vector<T>& v) {
    auto n = v.size();
    std::vector<T> t = v;

    auto comp = std::less<T>{};

    if (n % 2 == 0) {
        nth_element(t.begin(), t.begin() + n / 2, t.end(), comp);
        nth_element(t.begin(), t.begin() + (n - 1) / 2, t.end(), comp);
        return (t[(n - 1) / 2] + t[n / 2]) / 2;
    } else {
        nth_element(t.begin(), t.begin() + n / 2, t.end(), comp);
        return t[n / 2];
    }
}
