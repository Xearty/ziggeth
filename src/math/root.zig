pub fn pow(T: type, base: T, exponent: T) T {
    if (exponent == 0) return 1;
    if (exponent == 1) return base;

    if (exponent % 2 == 0) {
        const half_exponent = pow(T, base, exponent / 2);
        return half_exponent *% half_exponent;
    } else {
        const half_exponent = pow(T, base, (exponent - 1) / 2);
        return base *% half_exponent *% half_exponent;
    }
}

