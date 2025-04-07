#include <algorithm>
#include <ctime>
#include <vector>

using namespace std;

class Solution {
private:
    int lomutoPartition(vector<int>& arr, int low, int high) {
        swap(arr[low + rand() % (high - low + 1)], arr[high]);
        int pivot = arr[high], i = low - 1;
        for (int j = low; j < high; ++j)
            if (arr[j] < pivot) swap(arr[++i], arr[j]);
        swap(arr[++i], arr[high]);
        return i;
    }

    pair<int, int> lomutoPartition3(vector<int>& arr, int low, int high) {
        if (low >= high) {
            return {low, high};
        }

        swap(arr[low + rand() % (high - low + 1)], arr[low]);
        int pivot = arr[low];

        int lt = low;
        int gt = high;
        int i = low + 1;

        while (i <= gt) {
            if (arr[i] < pivot) {
                swap(arr[lt++], arr[i++]);
            } else if (arr[i] > pivot) {
                swap(arr[i], arr[gt--]);
            } else {
                i++;
            }
        }

        return {lt, gt};
    }

    int hoarePartition(vector<int>& arr, int low, int high) {
        int pivot = arr[low + rand() % (high - low + 1)];
        int i = low - 1;
        int j = high + 1;
        for (;;) {
            do {
            } while (arr[++i] < pivot);
            do {
            } while (arr[--j] > pivot);
            if (i >= j) return j;
            swap(arr[i], arr[j]);
        }
    }

    void quickSortLomuto(vector<int>& arr, int low, int high) {
        if (low < high) {
            int p = lomutoPartition(arr, low, high);
            quickSortLomuto(arr, low, p - 1);
            quickSortLomuto(arr, p + 1, high);
        }
    }
    void quickSortLomuto3(vector<int>& arr, int low, int high) {
        if (low < high) {
            pair<int, int> p = lomutoPartition3(arr, low, high);
            quickSortLomuto3(arr, low, p.first - 1);
            quickSortLomuto3(arr, p.second + 1, high);
        }
    }

    void quickSortHoare(vector<int>& arr, int low, int high) {
        if (low < high) {
            int p = hoarePartition(arr, low, high);
            quickSortHoare(arr, low, p);
            quickSortHoare(arr, p + 1, high);
        }
    }

public:
    vector<int> sortArray(vector<int>& arr) {
        srand(time(0));
        // quickSortLomuto(arr, 0, arr.size() - 1);
        quickSortHoare(arr, 0, arr.size() - 1);
        return arr;
    }
};
