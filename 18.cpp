#include <stack>

class MinStack {
private:
    std::stack<int> stack;
    std::stack<int> minstack;

public:
    void push(int val) {
        stack.push(val);
        if (minstack.empty() || val <= minstack.top()) {
            minstack.push(val);
        }
    }

    void pop() {
        if (stack.top() == minstack.top()) {
            minstack.pop();
        }
        stack.pop();
    }

    int top() const {
        return stack.top();
    }

    int getMin() const {
        return minstack.top();
    }
};
