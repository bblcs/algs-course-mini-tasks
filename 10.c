void swap(int *a, int *b) {
  int t = *a;
  *a = *b;
  *b = t;
}

void sortColors(int *n, int s) {
  ssize_t l = 0, m = 0, h = s - 1;
  while (m <= h) {
    if (n[m] == 0) {
      swap(&n[l++], &n[m++]);
    } else if (n[m] == 1) {
      m++;
    } else {
      swap(&n[m], &n[h--]);
    }
  }
}
