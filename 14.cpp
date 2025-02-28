struct ListNode {
  int val;
  ListNode *next;
  ListNode(int x) : val(x), next(nullptr) {}
};

class Solution {
public:
  ListNode *detectCycle(ListNode *head) {
    if (!head) {
      return nullptr;
    }

    auto *slow = head;
    auto *fast = head;

    auto first = true;

    while (fast != slow || first) {
      if (!fast || !fast->next)
        return nullptr;
      fast = fast->next->next;
      slow = slow->next;
      first = false;
    }

    fast = head;
    while (fast != slow) {
      fast = fast->next;
      slow = slow->next;
    }

    return slow;
  }
};
