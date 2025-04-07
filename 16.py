from enum import Enum


class Op(Enum):
    Pow = 1
    Mul = 2
    Div = 3
    Rem = 4
    Plus = 5
    Minus = 6
    LShift = 7
    RShift = 8
    Lt = 9
    Le = 10
    Gt = 11
    Ge = 12
    Eq = 13
    Ne = 14
    BitAnd = 15
    BitXor = 16
    BitOr = 17
    And = 18
    Or = 19


precedence = {
    Op.Or: 1,
    Op.And: 2,
    Op.BitOr: 3,
    Op.BitXor: 4,
    Op.BitAnd: 5,
    Op.Eq: 6,
    Op.Ne: 6,
    Op.Lt: 7,
    Op.Le: 7,
    Op.Gt: 7,
    Op.Ge: 7,
    Op.LShift: 8,
    Op.RShift: 8,
    Op.Plus: 9,
    Op.Minus: 9,
    Op.Mul: 10,
    Op.Div: 10,
    Op.Rem: 10,
    Op.Pow: 11,
}


associativity = {
    Op.Pow: "right",
    Op.Mul: "left",
    Op.Div: "left",
    Op.Rem: "left",
    Op.Plus: "left",
    Op.Minus: "left",
    Op.LShift: "left",
    Op.RShift: "left",
    Op.Lt: "left",
    Op.Le: "left",
    Op.Gt: "left",
    Op.Ge: "left",
    Op.Eq: "left",
    Op.Ne: "left",
    Op.BitAnd: "left",
    Op.BitXor: "left",
    Op.BitOr: "left",
    Op.And: "left",
    Op.Or: "left",
}


def infix_to_rpn(expression):
    output_queue = []
    operator_stack = []

    tokens = []
    i = 0
    while i < len(expression):
        if expression[i] == "(" or expression[i] == ")":
            tokens.append(expression[i])
            i += 1
        elif expression[i].isspace():
            i += 1
        else:
            token = ""
            while (
                i < len(expression)
                and not expression[i].isspace()
                and expression[i] != "("
                and expression[i] != ")"
            ):
                token += expression[i]
                i += 1
            tokens.append(token)

    def is_number(token):
        try:
            float(token)
            return True
        except ValueError:
            return False

    def str_to_op(token: str) -> Op | None:
        op_map = {
            "**": Op.Pow,
            "*": Op.Mul,
            "/": Op.Div,
            "%": Op.Rem,
            "+": Op.Plus,
            "-": Op.Minus,
            "<<": Op.LShift,
            ">>": Op.RShift,
            "<": Op.Lt,
            "<=": Op.Le,
            ">": Op.Gt,
            ">=": Op.Ge,
            "==": Op.Eq,
            "!=": Op.Ne,
            "&": Op.BitAnd,
            "^": Op.BitXor,
            "|": Op.BitOr,
            "&&": Op.And,
            "||": Op.Or,
        }
        return op_map.get(token)

    for token in tokens:
        if is_number(token):
            output_queue.append(token)
        elif token == "(":
            operator_stack.append(token)
        elif token == ")":
            while operator_stack and operator_stack[-1] != "(":
                output_queue.append(operator_stack.pop())
            if operator_stack and operator_stack[-1] == "(":
                operator_stack.pop()
            else:
                raise ValueError("mismatched parentheses")
        else:
            op = str_to_op(token)
            if op is None:
                raise ValueError(f"unknown token: {token}")

            while (
                operator_stack
                and operator_stack[-1] != "("
                and (
                    (
                        associativity[op] == "left"
                        and precedence[op]
                        <= precedence.get(str_to_op(operator_stack[-1]), -1)
                    )
                    or (
                        associativity[op] == "right"
                        and precedence[op]
                        < precedence.get(str_to_op(operator_stack[-1]), -1)
                    )
                )
            ):
                output_queue.append(operator_stack.pop())
            operator_stack.append(token)

    while operator_stack:
        if operator_stack[-1] == "(" or operator_stack[-1] == ")":
            raise ValueError("mismatched parentheses")
        output_queue.append(operator_stack.pop())

    return output_queue


if __name__ == "__main__":
    while True:
        expression = input("> ")
        if expression == "q":
            break

        try:
            rpn_expression = infix_to_rpn(expression)
            print(" ".join(rpn_expression))
        except ValueError as e:
            print("Error:", e)


def test_simple_addition():
    expression = "3 + 4"
    expected = ["3", "4", "+"]
    assert infix_to_rpn(expression), expected


def test_precedence():
    expression = "3 + 4 * 2"
    expected = ["3", "4", "2", "*", "+"]
    assert infix_to_rpn(expression), expected


def test_left_associativity():
    expression = "10 - 4 - 3"
    expected = ["10", "4", "-", "3", "-"]
    assert infix_to_rpn(expression), expected


def test_right_associativity():
    expression = "2 ** 3 ** 2"
    expected = ["2", "3", "2", "**", "**"]
    assert infix_to_rpn(expression), expected


def test_parentheses_override_precedence():
    expression = "(3 + 4) * 2"
    expected = ["3", "4", "+", "2", "*"]
    assert infix_to_rpn(expression), expected


def test_nested_parentheses():
    expression = "((1 + 2) * 3) - 4"
    expected = ["1", "2", "+", "3", "*", "4", "-"]
    assert infix_to_rpn(expression), expected


def test_whitespace_handling():
    expression = "  5  *  ( 6 +  2 ) / 4 "
    expected = ["5", "6", "2", "+", "*", "4", "/"]
    assert infix_to_rpn(expression), expected
