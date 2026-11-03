function H = tfbode_system(num, den)
    // Coefficients are supplied in DESCENDING powers, like [1 3 2].
    for c = list(num, den)
        if type(c) <> 1 then
            error("Coefficients must be numeric vectors.");
        end
        if isempty(c) | ~isreal(c) then
            error("Coefficients must be nonempty real vectors.");
        end
        if min(size(c)) <> 1 | or(isnan(c)) | or(isinf(c)) then
            error("Coefficients must be finite real vectors.");
        end
    end
    if and(den == 0) then
        error("The denominator cannot be zero.");
    end
    if and(num == 0) then
        error("The zero transfer function has no finite Bode magnitude or phase.");
    end
    num = matrix(num, 1, -1);
    den = matrix(den, 1, -1);
    H = syslin("c", poly(num($:-1:1), "s", "coeff"), ..
                    poly(den($:-1:1), "s", "coeff"));
endfunction
