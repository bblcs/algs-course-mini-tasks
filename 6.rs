impl Solution {
    pub fn sort_array(mut nums: Vec<i32>) -> Vec<i32> {
        let n = nums.len() - 1;
        Self::merge_sort(&mut nums, 0, n);
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

    fn merge(arr: &mut Vec<i32>, mut start: usize, mut mid: usize, end: usize) {
        let mut start2 = mid + 1;

        if (arr[mid] <= arr[start2]) {
            return;
        }

        while start <= mid && start2 <= end {
            if arr[start] <= arr[start2] {
                start += 1;
            } else {
                let val = arr[start2];
                let mut idx = start2;

                while idx != start {
                    arr[idx] = arr[idx - 1];
                    idx -= 1;
                }

                arr[start] = val;
                start += 1;
                mid += 1;
                start2 += 1;
            }
        }
    }
}
