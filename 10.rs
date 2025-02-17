impl Solution {
    pub fn sort_colors(nums: &mut Vec<i32>) {
        let mut l: usize = 0;
        let mut m: usize = 0;
        let mut h: isize = nums.len() as isize - 1;

        while m as isize <= h {
            match nums[m] {
                0 => {
                    nums.swap(l, m);
                    l += 1;
                    m += 1;
                }
                1 => m += 1,
                2 => {
                    nums.swap(m, h as usize);
                    h -= 1;
                }
                _ => panic!("wrong flag"),
            }
        }
    }
}
