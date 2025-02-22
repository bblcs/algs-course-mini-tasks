impl Solution {
    pub fn sort_array(mut nums: Vec<i32>) -> Vec<i32> {
        let n = nums.len();
        let mut buf = vec![0; n];
        Self::merge_sort(&mut nums, &mut buf, 0, n);
        nums
    }

    fn merge_sort(arr: &mut [i32], buf: &mut [i32], start: usize, end: usize) {
        if end - start <= 1 {
            return;
        }

        let mid = start + (end - start) / 2;
        Self::merge_sort(arr, buf, start, mid);
        Self::merge_sort(arr, buf, mid, end);

        Self::merge(arr, buf, start, mid, end);
    }

    fn merge(arr: &mut [i32], buf: &mut [i32], start: usize, mid: usize, end: usize) {
        let mut i = start;
        let mut j = mid;
        let mut k = start;

        while i < mid && j < end {
            if arr[i] <= arr[j] {
                buf[k] = arr[i];
                i += 1;
            } else {
                buf[k] = arr[j];
                j += 1;
            }
            k += 1;
        }

        while i < mid {
            buf[k] = arr[i];
            i += 1;
            k += 1;
        }

        while j < end {
            buf[k] = arr[j];
            j += 1;
            k += 1;
        }

        arr[start..end].copy_from_slice(&buf[start..end]);
    }
}
