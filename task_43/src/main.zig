const std = @import("std");
const Allocator = std.mem.Allocator;

pub const GTEPerTree = struct {
    const Node = struct {
        left: ?*const Node,
        right: ?*const Node,
        count: u32,
    };

    arena: std.heap.ArenaAllocator,
    roots: std.ArrayList(?*const Node),
    sorted_values: []i32,
    n: usize,

    pub fn init(allocator: Allocator, data: []const i32) !GTEPerTree {
        var arena = std.heap.ArenaAllocator.init(allocator);
        const arena_alloc = arena.allocator();

        const n = data.len;

        const Element = struct { val: i32, original_idx: usize };
        const elements = try arena_alloc.alloc(Element, n);
        for (data, 0..) |val, i| {
            elements[i] = .{ .val = val, .original_idx = i };
        }

        std.mem.sort(Element, elements, {}, struct {
            fn lessThan(_: void, lhs: Element, rhs: Element) bool {
                return lhs.val < rhs.val;
            }
        }.lessThan);

        const sorted = try arena_alloc.alloc(i32, n);
        for (elements, 0..) |e, i| sorted[i] = e.val;

        var roots = std.ArrayList(?*const Node).init(allocator);

        const initial = try buildEmpty(arena_alloc, 0, if (n > 0) n - 1 else 0);
        try roots.append(initial);

        var i: usize = 1;
        while (i <= n) : (i += 1) {
            const elem = elements[n - i];
            const prev = roots.items[i - 1];
            const new = try insert(arena_alloc, prev, 0, n - 1, elem.original_idx);
            try roots.append(new);
        }

        return .{
            .arena = arena,
            .roots = roots,
            .sorted_values = sorted,
            .n = n,
        };
    }

    pub fn deinit(self: *GTEPerTree) void {
        self.roots.deinit();
        self.arena.deinit();
    }

    pub fn gte(self: *GTEPerTree, l: usize, r: usize, k: i32) u32 {
        if (self.n == 0) return 0;
        if (l > r or l >= self.n) return 0;
        const safe_r = @min(r, self.n - 1);

        const idx = lowerBound(self.sorted_values, k);
        const version = self.sorted_values.len - idx;

        return findRec(self.roots.items[version], 0, self.n - 1, l, safe_r);
    }

    fn buildEmpty(allocator: Allocator, l: usize, r: usize) !*const Node {
        const node = try allocator.create(Node);
        if (l == r) {
            node.* = .{ .left = null, .right = null, .count = 0 };
            return node;
        }
        const mid = l + (r - l) / 2;
        node.left = try buildEmpty(allocator, l, mid);
        node.right = try buildEmpty(allocator, mid + 1, r);
        node.count = 0;
        return node;
    }

    fn insert(allocator: Allocator, prev: ?*const Node, l: usize, r: usize, pos: usize) !*const Node {
        const node = try allocator.create(Node);
        if (prev) |p| node.* = p.* else node.* = .{ .left = null, .right = null, .count = 0 };

        if (l == r) {
            node.count += 1;
            return node;
        }

        const mid = l + (r - l) / 2;
        if (pos <= mid) {
            node.left = try insert(allocator, node.left, l, mid, pos);
        } else {
            node.right = try insert(allocator, node.right, mid + 1, r, pos);
        }

        const c_left = if (node.left) |n| n.count else 0;
        const c_right = if (node.right) |n| n.count else 0;
        node.count = c_left + c_right;
        return node;
    }

    fn findRec(node_opt: ?*const Node, l: usize, r: usize, ql: usize, qr: usize) u32 {
        if (ql > r or qr < l) return 0;
        const node = node_opt orelse return 0;

        if (ql <= l and r <= qr) return node.count;

        const mid = l + (r - l) / 2;
        return findRec(node.left, l, mid, ql, qr) +
            findRec(node.right, mid + 1, r, ql, qr);
    }

    fn lowerBound(arr: []const i32, val: i32) usize {
        var low: usize = 0;
        var high: usize = arr.len;
        while (low < high) {
            const mid = low + (high - low) / 2;
            if (arr[mid] >= val) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return low;
    }
};

test "base" {
    const allocator = std.testing.allocator;
    const data = [_]i32{ 1, 5, 5, 2, 5 };

    var tree = try GTEPerTree.init(allocator, &data);
    defer tree.deinit();

    try std.testing.expectEqual(3, tree.gte(0, 4, 5));
    try std.testing.expectEqual(2, tree.gte(1, 3, 3));
    try std.testing.expectEqual(0, tree.gte(0, 4, 6));
}

test "random" {
    const allocator = std.testing.allocator;
    var prng = std.Random.DefaultPrng.init(999);
    const random = prng.random();

    const loops = 1000;
    for (0..loops) |_| {
        const n = random.intRangeAtMost(usize, 1, 100);
        var data = try allocator.alloc(i32, n);
        defer allocator.free(data);
        for (0..n) |i| data[i] = random.intRangeAtMost(i32, -50, 50);

        var tree = try GTEPerTree.init(allocator, data);
        defer tree.deinit();

        for (0..20000) |_| {
            const l = random.intRangeAtMost(usize, 0, n - 1);
            const r = random.intRangeAtMost(usize, l, n - 1);
            const k = random.intRangeAtMost(i32, -99999999, 99999999);

            const actual = tree.gte(l, r, k);

            var expected: u32 = 0;
            var i: usize = l;
            while (i <= r) : (i += 1) {
                if (data[i] >= k) expected += 1;
            }
            try std.testing.expectEqual(expected, actual);
        }
    }
}
