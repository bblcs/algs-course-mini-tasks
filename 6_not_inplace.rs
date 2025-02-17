impl Solution {
    pub fn sort_array(mut nums: Vec<i32>) -> Vec<i32> {
        let n = nums.len();
        Self::merge_sort(&mut nums, 0, n - 1);
        nums
    }

    fn merge_sort(arr: &mut Vec<i32>, l: usize, r: usize) {
        if l < r {
            let m = l + (r - l) / 2;
            Self::merge_sort(arr, l, m);
            Self::merge_sort(arr, m + 1, r);
            Self::merge(arr, l, m, r);
        }
    }

    fn merge(arr: &mut Vec<i32>, start: usize, mid: usize, end: usize) {
        let mut left = Vec::with_capacity(mid - start + 1);
        let mut right = Vec::with_capacity(end - mid);

        for i in 0..mid - start + 1 {
            left.push(arr[start + i]);
        }
        for j in 0..end - mid {
            right.push(arr[mid + 1 + j]);
        }

        let mut i = 0;
        let mut j = 0;
        let mut k = start;

        while i < left.len() && j < right.len() {
            if left[i] <= right[j] {
                arr[k] = left[i];
                i += 1;
            } else {
                arr[k] = right[j];
                j += 1;
            }
            k += 1;
        }

        while i < left.len() {
            arr[k] = left[i];
            i += 1;
            k += 1;
        }

        while j < right.len() {
            arr[k] = right[j];
            j += 1;
            k += 1;
        }
    }
}
