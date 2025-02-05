class Karatsuba {
    static BigInteger multiply(BigInteger x, BigInteger y) {
        int n = Math.max(x.toString().length(), y.toString().length())
        if (n <= 1) {
            return x * y
        }

        int halfN = n / 2
        BigInteger a = x / BigInteger.valueOf(10).pow(halfN)
        BigInteger b = x % BigInteger.valueOf(10).pow(halfN)
        BigInteger c = y / BigInteger.valueOf(10).pow(halfN)
        BigInteger d = y % BigInteger.valueOf(10).pow(halfN)

        BigInteger ac = multiply(a, c)
        BigInteger bd = multiply(b, d)
        BigInteger adPlusBc = multiply(a + b, c + d) - ac - bd


        return ac * BigInteger.valueOf(10).pow(2 * halfN) + adPlusBc * BigInteger.valueOf(10).pow(halfN) + bd
    }
}

assert Karatsuba.multiply(BigInteger.valueOf(3),          BigInteger.valueOf(5))         == 15
assert Karatsuba.multiply(BigInteger.valueOf(12),         BigInteger.valueOf(12))        == 144
assert Karatsuba.multiply(BigInteger.valueOf(123),        BigInteger.valueOf(456))       == 56088
assert Karatsuba.multiply(BigInteger.valueOf(1000),       BigInteger.valueOf(1000))      == 1000000
assert Karatsuba.multiply(BigInteger.valueOf(101),        BigInteger.valueOf(101))       == 10201
assert Karatsuba.multiply(BigInteger.valueOf(12345),      BigInteger.valueOf(67890))     == 838102050
assert Karatsuba.multiply(BigInteger.valueOf(99999),      BigInteger.valueOf(99999))     == 9999800001
assert Karatsuba.multiply(BigInteger.valueOf(1234567890), BigInteger.valueOf(987654321)) ==  new BigInteger("1219326311126352690")
assert Karatsuba.multiply(new BigInteger("12345678901234567890"), new BigInteger("98765432109876543210")) == new BigInteger("1219326311370217952237463801111263526900")
println("All tests passed!")
