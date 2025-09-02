// https://leetcode.com/problems/jump-game/submissions/1755795848/

impl Solution {
    pub fn can_jump(nums: Vec<i32>) -> bool {
        let n = nums.len();
        let mut farest = 0;
        for i in 0..n {
            if i > farest {
                return false;
            }
            farest = farest.max(i + nums[i] as usize);
            if farest >= n - 1 {
                return true;
            }
        }
        false
    }
}
