class Solution {

    /**
     * @param Integer[] $nums
     * @return NULL
     */
    function wiggleSort(&$nums) {
        $n = count($nums);

        $gaps = [];
        $i = 1;
        while ((2**$i - 1) < $n) {
            $gaps[] = 2**$i - 1;
            $i++;
        }
        $gaps = array_reverse($gaps);

        foreach ($gaps as $gap) {
            for ($i = $gap; $i < $n; $i++) {
                $t = $nums[$i];
                $j = $i;

                while ($j >= $gap && $nums[$j - $gap] > $t) {
                    $nums[$j] = $nums[$j - $gap];
                    $j -= $gap;
                }
                $nums[$j] = $t;
            }
        }

        $mid = (int)(($n - 1) / 2);
        $t = $nums;
        $left = $mid;
        $right = $n - 1;

        for ($i = 0; $i < $n; $i++) {
            if ($i % 2 == 0) {
                $nums[$i] = $t[$left];
                $left--;
            } else {
                $nums[$i] = $t[$right];
                $right--;
            }
        }
    }
}
