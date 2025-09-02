// https://leetcode.com/problems/best-time-to-buy-and-sell-stock-ii/submissions/1755818835/

impl Solution {
    fn no_micro_trading(p: &Vec<i32>) -> i32 {
        let n = p.len();
        let mut sum = 0;
        let mut i = 0;
        while i + 1 < n {
            while (i + 1 < n && p[i] > p[i + 1]) {
                i += 1;
            }
            sum -= p[i];

            while (i + 1 < n && p[i] < p[i + 1]) {
                i += 1;
            }
            sum += p[i];

            i += 1;
        }

        sum.max(0)
    }

    fn micro_trading(p: &Vec<i32>) -> i32 {
        let n = p.len();
        let mut sum = 0;
        for i in 0..n - 1 {
            if p[i] < p[i + 1] {
                sum += p[i + 1] - p[i];
            }
        }

        sum
    }

    pub fn max_profit(p: Vec<i32>) -> i32 {
        Self::no_micro_trading(&p) // style points
                                   //Self::micro_trading(&p)
    }
}
