class Karatsuba {
    static BigInteger multiply(BigInteger x, BigInteger y) {
        int n = Math.max(x.toString().length(), y.toString().length())
        if (n <= 80) {
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

assert Karatsuba.multiply(BigInteger.valueOf(3), BigInteger.valueOf(15)) == 45
assert Karatsuba.multiply(BigInteger.valueOf(2), BigInteger.valueOf(12323)) == 24646
assert Karatsuba.multiply(BigInteger.valueOf(123123), BigInteger.valueOf(3322233223322)) == 409043321155074606
assert Karatsuba.multiply(BigInteger.valueOf(1000), BigInteger.valueOf(10001000)) == 10001000000
assert Karatsuba.multiply(BigInteger.valueOf(101010101010101), BigInteger.valueOf(101010010101010110)) == 10203031323334353525151413121110
assert Karatsuba.multiply(new BigInteger("1818181818181818181818181818181818181818"), new BigInteger("92929292929292929292929292929")) == new BigInteger("168962350780532598714416896234545454545437649219467401285583103764922")
println("All tests passed!")
