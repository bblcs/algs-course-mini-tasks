struct ListNode {
  int val;
  ListNode *next;
  ListNode() : val(0), next(nullptr) {}
  ListNode(int x) : val(x), next(nullptr) {}
  ListNode(int x, ListNode *next) : val(x), next(next) {}
};

class Solution {
public:
  ListNode *reverseBetween(ListNode *head, int left, int right) {
    if (!head || left == right) {
      return head;
    }

    auto *t = new ListNode();
    t->next = head;
    auto *start = t;

    for (auto i = 0; i < left - 1; i++) {
      start = start->next;
    }

    auto *cur = start->next;

    for (auto i = 0; i < right - left; i++) {
      ListNode *moved = cur->next;
      cur->next = moved->next;
      moved->next = start->next;
      start->next = moved;
    }

    return t->next;
  }
};
