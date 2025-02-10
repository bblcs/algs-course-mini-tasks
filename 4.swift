class Solution {
    func hIndex(_ citations: [Int]) -> Int {
        var citations = citations
        let n = citations.count

        var gaps: [Int] = []
        var i = 1
        while true {
            let gap = (1 << i) - 1
            if gap <= n {
                gaps.append(gap)
                i += 1
            } else {
                break
            }
        }

        gaps = gaps.reversed()

        for gap in gaps {
            for i in gap..<n {
                let t = citations[i]
                var j = i
                while j >= gap && citations[j - gap] < t {
                    citations[j] = citations[j - gap]
                    j -= gap
                }
                citations[j] = t
            }
        }

        var h = 0
        for i in 0..<n {
            if citations[i] >= i + 1 {
                h = i + 1
            } else {
                break
            }
        }

        return h
    }
}
