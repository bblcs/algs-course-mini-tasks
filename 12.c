#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void swap(int *a, int *b) {
  int t = *a;
  *a = *b;
  *b = t;
}

int lomutoPartition(int *arr, int low, int high) {
  swap(&arr[low + rand() % (high - low + 1)], &arr[high]);
  int pivot = arr[high], i = low - 1;
  for (int j = low; j < high; ++j)
    if (arr[j] < pivot)
      swap(&arr[++i], &arr[j]);
  swap(&arr[++i], &arr[high]);
  return i;
}

int hoarePartition(int *arr, int low, int high) {
  int pivot = arr[low + rand() % (high - low + 1)];
  int i = low - 1;
  int j = high + 1;
  for (;;) {
    do {
      i++;
    } while (arr[i] < pivot);
    do {
      j--;
    } while (arr[j] > pivot);
    if (i >= j)
      return j;
    swap(&arr[i], &arr[j]);
  }
}

int *lomutoPartitionBF(int *first, int *last) {
  assert(first <= last);
  if (last - first < 2)
    return first;

  last--;
  if (*first > *last)
    swap(first, last);

  int *pivot_pos = first;
  int pivot = *first;

  do {
    first++;
    assert(first <= last);
  } while (*first < pivot);

  for (int *read = first + 1; read < last; read++) {
    int x = *read;
    int smaller = -(x < pivot);
    int delta = smaller & (read - first);
    first[delta] = *first;
    read[-delta] = x;
    first -= smaller;
  }

  assert(*first >= pivot);
  first--;
  *pivot_pos = *first;
  *first = pivot;
  return first;
}

void quickSortLomuto(int *arr, int low, int high) {
  if (low < high) {
    int p = lomutoPartition(arr, low, high);
    quickSortLomuto(arr, low, p - 1);
    quickSortLomuto(arr, p + 1, high);
  }
}

void quickSortHoare(int *arr, int low, int high) {
  if (low < high) {
    int p = hoarePartition(arr, low, high);
    quickSortHoare(arr, low, p);
    quickSortHoare(arr, p + 1, high);
  }
}

void quickSortLomutoBF(int *arr, int low, int high) {
  if (low < high) {
    int *p = lomutoPartitionBF(arr + low, arr + high + 1);
    int idx_p = p - arr;
    quickSortLomutoBF(arr, low, idx_p - 1);
    quickSortLomutoBF(arr, idx_p + 1, high);
  }
}

void copyArray(int *src, int *dest, size_t sz) {
  for (size_t i = 0; i < sz; i++) {
    dest[i] = src[i];
  }
}

double calculateAverage(double *data, size_t sz) {
  double sum = 0.0;
  for (size_t i = 0; i < sz; i++) {
    sum += data[i];
  }
  return sum / sz;
}

double calculateGeoMean(double *arr, size_t sz) {
  double prod = 1.0;
  for (size_t i = 0; i < sz; i++) {
    prod *= arr[i];
  }
  return pow(prod, 1.0 / sz);
}

double calculateStdDev(double *arr, size_t sz, double average) {
  double sum_of_squares = 0.0;
  for (size_t i = 0; i < sz; i++) {
    sum_of_squares += pow(arr[i] - average, 2);
  }
  return sqrt(sum_of_squares / sz);
}

void benchmarkSort(char *name, void (*sortFunction)(int *, int, int), int *arr,
                   size_t sz, size_t n_runs) {
  clock_t start, end;
  double time_taken;
  double runtimes[n_runs];

  printf("benchmarking %s:\t", name);

  for (size_t i = 0; i < n_runs; i++) {
    int *tbuf = (int *)malloc(sz * sizeof(int));
    copyArray(arr, tbuf, sz);

    start = clock();
    sortFunction(tbuf, 0, sz - 1);
    end = clock();

    time_taken = ((double)(end - start)) / CLOCKS_PER_SEC;
    runtimes[i] = time_taken;
    free(tbuf);
  }

  double average = calculateAverage(runtimes, n_runs);
  double geomean = calculateGeoMean(runtimes, n_runs);
  double stddev = calculateStdDev(runtimes, n_runs, average);

  printf("Avg: %fs\t ", average);
  printf("GeoMean: %fs\t", geomean);
  printf("StdDev: %fs\n", stddev);
}

int main() {
  srand(time(NULL));

  size_t sizes[] = {100000, 200000, 300000, 400000, 504040};
  size_t n_sizes = sizeof(sizes) / sizeof(sizes[0]);
  size_t n_runs = 100;

  for (size_t s = 0; s < n_sizes; s++) {
    size_t size = sizes[s];
    printf("array size: %zu\n", size);

    int *arr = (int *)malloc(size * sizeof(int));

    for (size_t i = 0; i < size; i++) {
      arr[i] = rand() % 100000;
    }

    benchmarkSort("Lomuto", quickSortLomuto, arr, size, n_runs);
    benchmarkSort("Hoare", quickSortHoare, arr, size, n_runs);
    benchmarkSort("Lomuto-BF", quickSortLomutoBF, arr, size, n_runs);

    free(arr);
  }

  return 0;
}
