#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <random>
#include <set>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

using IP = uint32_t;

inline IP parse_ip(const std::string& ip_str) {
    std::stringstream ss(ip_str);
    IP ip = 0;
    for (int i = 0; i < 4; ++i) {
        IP segment;
        char dot;
        ss >> segment;
        ip = (ip << 8) | segment;
        if (i < 3) {
            ss >> dot;
        }
    }
    return ip;
}

class BloomFilter {
public:
    BloomFilter(size_t n, double p)
        : expected_elements_(n), false_positive_prob_(p), rng_(std::random_device{}()) {
        if (n == 0) {
            m_ = 1;
            k_ = 0;
            bits_.resize(m_, false);
            return;
        }
        // m = - (n * ln(p)) / (ln(2)^2)
        // k = (m / n) * ln(2)
        double ln2 = std::log(2.0);
        double ln2_squared = ln2 * ln2;

        m_ = std::max(1.0, std::ceil(-(static_cast<double>(n) * std::log(p)) / ln2_squared));
        k_ = std::max(1.0, std::round((static_cast<double>(m_) / static_cast<double>(n)) * ln2));

        bits_.resize(static_cast<size_t>(m_), false);

        // h_ab(x) = ((a*x + b) % P) % m
        std::uniform_int_distribution<uint64_t> dist_a(1, PRIME_P - 1);
        std::uniform_int_distribution<uint64_t> dist_b(0, PRIME_P - 1);

        hash_params_.reserve(static_cast<size_t>(k_));
        for (int i = 0; i < static_cast<size_t>(k_); i++) {
            hash_params_.emplace_back(dist_a(rng_), dist_b(rng_));
        }
    }

    void insert(IP ip) {
        if (k_ == 0) return;

        for (int i = 0; i < k_; i++) {
            int idx = calculate_hash(i, ip);
            bits_[idx] = true;
        }
    }

    void insert(const std::string& ip_str) {
        IP ip = parse_ip(ip_str);
        insert(ip);
    }

    [[nodiscard]] bool lookup(IP ip) const {
        if (k_ == 0) return false;

        for (int i = 0; i < k_; i++) {
            int idx = calculate_hash(i, ip);
            if (!bits_[idx]) {
                return false;
            }
        }
        return true;
    }

    [[nodiscard]] bool lookup(const std::string& ip_str) const {
        IP ip = parse_ip(ip_str);
        return lookup(ip);
    }

    [[nodiscard]] size_t bit_array_size() const {
        return static_cast<size_t>(m_);
    }
    [[nodiscard]] size_t num_hash_functions() const {
        return static_cast<size_t>(k_);
    }
    [[nodiscard]] size_t expected_elements() const {
        return expected_elements_;
    }
    [[nodiscard]] double desired_false_positive_prob() const {
        return false_positive_prob_;
    }

private:
    static constexpr uint64_t PRIME_P = 4294967311ULL;

    size_t expected_elements_;
    double false_positive_prob_;
    double m_;
    double k_;

    std::vector<bool> bits_;
    std::vector<std::pair<uint64_t, uint64_t>> hash_params_;

    std::mt19937 rng_;

    [[nodiscard]] int calculate_hash(int i, IP ip) const {
        const auto& params = hash_params_[i];
        uint64_t a = params.first;
        uint64_t b = params.second;
        uint64_t ip_64 = static_cast<uint64_t>(ip);

        // (a * ip + b) mod P
        uint64_t hash_val = (a * ip_64 + b) % PRIME_P;
        size_t bit_array_actual_size = static_cast<size_t>(m_);
        return static_cast<size_t>(hash_val % bit_array_actual_size);
    }
};

IP random_ip(std::mt19937& gen) {
    std::uniform_int_distribution<IP> dist(0, 0xFFFFFFFF);
    return dist(gen);
}

int main() {
    const size_t num_insertions = 10000;
    const double target_fp_rate = 0.01;

    BloomFilter bf(num_insertions, target_fp_rate);

    std::mt19937 gen(1);
    std::set<IP> inserted_ips;
    std::set<IP> not_inserted_ips;

    while (inserted_ips.size() < num_insertions) {
        IP ip = random_ip(gen);
        if (inserted_ips.find(ip) == inserted_ips.end()) {
            inserted_ips.insert(ip);
            bf.insert(ip);
        }
    }

    const size_t num_test_ips = num_insertions * 10;
    while (not_inserted_ips.size() < num_test_ips) {
        IP ip = random_ip(gen);
        if (inserted_ips.find(ip) == inserted_ips.end() &&
            not_inserted_ips.find(ip) == not_inserted_ips.end()) {
            not_inserted_ips.insert(ip);
        }
    }

    size_t false_positives = 0;
    for (IP test_ip : not_inserted_ips) {
        if (bf.lookup(test_ip)) {
            false_positives++;
        }
    }

    double observed_fp_rate = static_cast<double>(false_positives) / not_inserted_ips.size();

    std::cout << "target fp rate: " << target_fp_rate << std::endl;
    std::cout << "n: " << bf.expected_elements() << std::endl;
    std::cout << "m: " << bf.bit_array_size() << std::endl;
    std::cout << "k: " << bf.num_hash_functions() << std::endl;
    std::cout << "non-members: " << not_inserted_ips.size() << std::endl;
    std::cout << "fps found: " << false_positives << std::endl;
    std::cout << "fp rate: " << observed_fp_rate << std::endl;
}
