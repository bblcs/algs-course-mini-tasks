#include <queue>

struct ListNode {
    int val;
    ListNode* next;
    ListNode() : val(0), next(nullptr) {}
    ListNode(int x) : val(x), next(nullptr) {}
    ListNode(int x, ListNode* next) : val(x), next(next) {}
};

class Solution {
public:
    ListNode* mergeKLists(std::vector<ListNode*>& lists) {
        auto cmp = [](ListNode* a, ListNode* b) { return a->val > b->val; };
        std::priority_queue<ListNode*, std::vector<ListNode*>, decltype(cmp)> pq(cmp);

        for (auto* list : lists) {
            if (list) {
                pq.push(list);
            }
        }

        ListNode t(0);
        ListNode* cur = &t;

        while (!pq.empty()) {
            ListNode* lesser = pq.top();
            pq.pop();

            cur->next = lesser;
            cur = cur->next;

            if (lesser->next) {
                pq.push(lesser->next);
            }
        }

        return t.next;
    }
};
