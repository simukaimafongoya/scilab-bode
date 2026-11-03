function H = tfbode_system(num, den, sample_time)
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
    domain = "c"; variable = "s";
    if argn(2) >= 3 then
        tfbode_sample_time(sample_time);
        domain = sample_time; variable = "z";
    end
    H = syslin(domain, poly(num($:-1:1), variable, "coeff"), ..
                       poly(den($:-1:1), variable, "coeff"));
endfunction
