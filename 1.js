const rl = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout,
});

function cdiv(dividend, divisor) {
  const dividend_d = dividend.split('').map(Number);
  const divisor_d = divisor.split('').map(Number);
  const divisor_n = parseInt(divisor_d.join(''));
  const n = dividend_d.length;
  const m = divisor_d.length;

  if (m === 0 || (m === 1 && divisor_d[0] === 0)) {
    return "death";
  }

  if (n < m) {
    return "0";
  }

  if (parseInt(dividend) < parseInt(divisor)) {
    return "0"
  }

  let quotient = [];
  let rem_d = [];

  for (let i = 0; i < n; i++) {
    rem_d.push(dividend_d[i]);

    let rem_n = parseInt(rem_d.join(''));  // O(10m) ~ O(m)

    if (rem_n < divisor_n) {
      quotient.push(0);
      continue;
    }

    let q = 0;

    while (rem_n >= divisor_n) {
      rem_n -= divisor_n;
      q++;
    }

    quotient.push(q);
    rem_d = String(rem_n).split("").map(Number)
  }

  while (quotient[0] === 0 && quotient.length > 1) {
    quotient.shift();
  }

  return quotient.join('');
}

rl.question('', (dividend) => {
  rl.question('', (divisor) => {
    const result = cdiv(dividend, divisor);
    console.log(result);
    rl.close();
  });
});
