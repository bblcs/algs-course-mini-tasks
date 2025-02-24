use rand::Rng;
use std::collections::HashMap;
use std::fmt;
use std::time::{Duration, Instant};

type Matrix = Vec<Vec<f32>>;

fn generate_random_matrix(size: usize) -> Matrix {
    let mut rng = rand::rng();
    (0..size)
        .map(|_| (0..size).map(|_| rng.random::<f32>()).collect())
        .collect()
}

// O(n^3)
fn classical_matrix_multiply(a: &Matrix, b: &Matrix) -> Matrix {
    let n = a.len();
    let mut result = vec![vec![0.0; n]; n];

    for i in 0..n {
        for j in 0..n {
            for k in 0..n {
                result[i][j] += a[i][k] * b[k][j];
            }
        }
    }

    result
}

fn matrix_add(a: &Matrix, b: &Matrix) -> Matrix {
    let n = a.len();
    let mut result = vec![vec![0.0; n]; n];
    for i in 0..n {
        for j in 0..n {
            result[i][j] = a[i][j] + b[i][j];
        }
    }
    result
}

fn matrix_subtract(a: &Matrix, b: &Matrix) -> Matrix {
    let n = a.len();
    let mut result = vec![vec![0.0; n]; n];
    for i in 0..n {
        for j in 0..n {
            result[i][j] = a[i][j] - b[i][j];
        }
    }
    result
}

// O(n^3)
fn recursive_matrix_multiply(a: &Matrix, b: &Matrix) -> Matrix {
    let n = a.len();

    if n == 1 {
        return vec![vec![a[0][0] * b[0][0]]];
    }

    let half_n = n / 2;

    // Partition matrices
    let mut a11 = vec![vec![0.0; half_n]; half_n];
    let mut a12 = vec![vec![0.0; half_n]; half_n];
    let mut a21 = vec![vec![0.0; half_n]; half_n];
    let mut a22 = vec![vec![0.0; half_n]; half_n];
    let mut b11 = vec![vec![0.0; half_n]; half_n];
    let mut b12 = vec![vec![0.0; half_n]; half_n];
    let mut b21 = vec![vec![0.0; half_n]; half_n];
    let mut b22 = vec![vec![0.0; half_n]; half_n];

    for i in 0..half_n {
        for j in 0..half_n {
            a11[i][j] = a[i][j];
            a12[i][j] = a[i][j + half_n];
            a21[i][j] = a[i + half_n][j];
            a22[i][j] = a[i + half_n][j + half_n];
            b11[i][j] = b[i][j];
            b12[i][j] = b[i][j + half_n];
            b21[i][j] = b[i + half_n][j];
            b22[i][j] = b[i + half_n][j + half_n];
        }
    }

    let c11 = matrix_add(
        &recursive_matrix_multiply(&a11, &b11),
        &recursive_matrix_multiply(&a12, &b21),
    );
    let c12 = matrix_add(
        &recursive_matrix_multiply(&a11, &b12),
        &recursive_matrix_multiply(&a12, &b22),
    );
    let c21 = matrix_add(
        &recursive_matrix_multiply(&a21, &b11),
        &recursive_matrix_multiply(&a22, &b21),
    );
    let c22 = matrix_add(
        &recursive_matrix_multiply(&a21, &b12),
        &recursive_matrix_multiply(&a22, &b22),
    );

    let mut result = vec![vec![0.0; n]; n];
    for i in 0..half_n {
        for j in 0..half_n {
            result[i][j] = c11[i][j];
            result[i][j + half_n] = c12[i][j];
            result[i + half_n][j] = c21[i][j];
            result[i + half_n][j + half_n] = c22[i][j];
        }
    }

    result
}

// O(n^log2(7))
fn strassen_matrix_multiply(a: &Matrix, b: &Matrix) -> Matrix {
    let n = a.len();

    if n <= 64 {
        return classical_matrix_multiply(a, b);
    }

    let half_n = n / 2;

    let mut a11 = vec![vec![0.0; half_n]; half_n];
    let mut a12 = vec![vec![0.0; half_n]; half_n];
    let mut a21 = vec![vec![0.0; half_n]; half_n];
    let mut a22 = vec![vec![0.0; half_n]; half_n];
    let mut b11 = vec![vec![0.0; half_n]; half_n];
    let mut b12 = vec![vec![0.0; half_n]; half_n];
    let mut b21 = vec![vec![0.0; half_n]; half_n];
    let mut b22 = vec![vec![0.0; half_n]; half_n];

    for i in 0..half_n {
        for j in 0..half_n {
            a11[i][j] = a[i][j];
            a12[i][j] = a[i][j + half_n];
            a21[i][j] = a[i + half_n][j];
            a22[i][j] = a[i + half_n][j + half_n];
            b11[i][j] = b[i][j];
            b12[i][j] = b[i][j + half_n];
            b21[i][j] = b[i + half_n][j];
            b22[i][j] = b[i + half_n][j + half_n];
        }
    }

    let m1 = strassen_matrix_multiply(&matrix_add(&a11, &a22), &matrix_add(&b11, &b22));
    let m2 = strassen_matrix_multiply(&matrix_add(&a21, &a22), &b11);
    let m3 = strassen_matrix_multiply(&a11, &matrix_subtract(&b12, &b22));
    let m4 = strassen_matrix_multiply(&a22, &matrix_subtract(&b21, &b11));
    let m5 = strassen_matrix_multiply(&matrix_add(&a11, &a12), &b22);
    let m6 = strassen_matrix_multiply(&matrix_subtract(&a21, &a11), &matrix_add(&b11, &b12));
    let m7 = strassen_matrix_multiply(&matrix_subtract(&a12, &a22), &matrix_add(&b21, &b22));

    let c11 = matrix_add(&matrix_subtract(&matrix_add(&m1, &m4), &m5), &m7);
    let c12 = matrix_add(&m3, &m5);
    let c21 = matrix_add(&m2, &m4);
    let c22 = matrix_add(&matrix_subtract(&matrix_add(&m1, &m3), &m2), &m6);

    let mut result = vec![vec![0.0; n]; n];
    for i in 0..half_n {
        for j in 0..half_n {
            result[i][j] = c11[i][j];
            result[i][j + half_n] = c12[i][j];
            result[i + half_n][j] = c21[i][j];
            result[i + half_n][j + half_n] = c22[i][j];
        }
    }

    result
}

fn measure_execution_time(
    algorithm: &dyn Fn(&Matrix, &Matrix) -> Matrix,
    a: &Matrix,
    b: &Matrix,
) -> Duration {
    let start = Instant::now();
    algorithm(a, b);
    start.elapsed()
}

struct TimingResult {
    mean: Duration,
    std_dev: f64,
    geometric_mean: f64,
}

impl fmt::Display for TimingResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "Mean: {:?}, StdDev: {:.6}, GeometricMean: {:.6}",
            self.mean, self.std_dev, self.geometric_mean
        )
    }
}

fn calculate_statistics(durations: &[Duration]) -> TimingResult {
    let n = durations.len() as f64;

    let sum: Duration = durations.iter().sum();
    let mean = sum / durations.len() as u32;

    let duration_f64: Vec<f64> = durations.iter().map(|&d| d.as_secs_f64()).collect();

    let sum_of_squares: f64 = duration_f64
        .iter()
        .map(|&d| (d - mean.as_secs_f64()).powi(2))
        .sum();
    let std_dev = (sum_of_squares / n).sqrt();

    let product: f64 = duration_f64.iter().product();
    let geometric_mean = product.powf(1.0 / n);

    TimingResult {
        mean,
        std_dev,
        geometric_mean,
    }
}

fn run_test_bench(
    algorithms: &HashMap<&str, &dyn Fn(&Matrix, &Matrix) -> Matrix>,
    input_sizes: &[usize],
    num_runs: usize,
) {
    println!("Test Bench Results:\n");
    println!(
        "Number of runs per algorithm and matrix size: {}\n",
        num_runs
    );

    for &size in input_sizes {
        println!("Matrix Size: {}x{}", size, size);
        let a = generate_random_matrix(size);
        let b = generate_random_matrix(size);

        for (name, algorithm) in algorithms {
            let mut durations: Vec<Duration> = Vec::new();

            for _ in 0..num_runs {
                durations.push(measure_execution_time(*algorithm, &a, &b));
            }

            let stats = calculate_statistics(&durations);
            println!("  {}: {}", name, stats);
        }
        println!();
    }
}

fn main() {
    let mut algorithms: HashMap<&str, &dyn Fn(&Matrix, &Matrix) -> Matrix> = HashMap::new();
    algorithms.insert("Classical", &classical_matrix_multiply);
    algorithms.insert("Strassen ", &strassen_matrix_multiply);
    algorithms.insert("Recursive", &recursive_matrix_multiply);

    let input_sizes = [32, 64, 128, 256, 512, 1024];

    let num_runs = 10;

    run_test_bench(&algorithms, &input_sizes, num_runs);
}
