fn lsd_radix_sort(arr: &mut [String]) {
    if arr.is_empty() {
        return;
    }

    let len = arr[0].len();

    for d in (0..len).rev() {
        counts_digit(arr, d);
    }
}

fn counts_digit(arr: &mut [String], digit: usize) {
    let n = arr.len();
    let mut count = [0; 256];
    let mut out = vec!["".to_string(); n];

    for s in arr.iter() {
        let idx = s.as_bytes()[digit] as usize;
        count[idx] += 1;
    }

    for i in 1..256 {
        count[i] += count[i - 1];
    }

    for i in (0..n).rev() {
        let s = &arr[i];
        let idx = s.as_bytes()[digit] as usize;
        out[count[idx] - 1] = s.to_string();
        count[idx] -= 1;
    }

    arr[..n].clone_from_slice(&out[..n]);
}

#[cfg(test)]
mod tests {
    use super::*;
    use rand::Rng;
    use rand_distr::Alphanumeric;

    fn gen_random_strarr(sz: usize, len: usize) -> Vec<String> {
        let mut rng = rand::rng();
        (0..sz)
            .map(|_| {
                (0..len)
                    .map(|_| rng.sample(Alphanumeric) as char)
                    .collect::<String>()
            })
            .collect()
    }

    macro_rules! test_sort {
        ($sz:literal, $len:literal) => {
            paste::item! {
                #[test]
                fn [< test_ $sz _ $len >] () {
                    let mut arr = gen_random_strarr($sz, $len);
                    let mut arr_clone = arr.clone();
                    lsd_radix_sort(&mut arr);
                    arr_clone.sort_unstable();
                    assert_eq!(arr, arr_clone);
                }
            }
        };
    }

    test_sort!(1, 1);
    test_sort!(2, 2);
    test_sort!(3, 3);
    test_sort!(10, 10);
    test_sort!(15, 3);
    test_sort!(100, 100);
    test_sort!(1, 100);
    test_sort!(100, 1);
}

// use `cargo test`
fn main() {}
