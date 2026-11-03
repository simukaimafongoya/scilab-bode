function values = tfbode_numbers(text)
    // Parse numeric tokens without executing user-entered Scilab expressions.
    text = strsubst(strsubst(strsubst(text, "[", " "), "]", " "), ",", " ");
    parts = tokens(text);
    if isempty(parts) then error("Enter at least one number."); end
    values = zeros(1, size(parts, "*"));
    for k = 1:size(parts, "*")
        [value, tail] = strtod(parts(k));
        if tail <> "" | isnan(value) | isinf(value) then
            error("Use finite numbers separated by spaces or commas, e.g. 1 0.5 10.");
        end
        values(k) = value;
    end
endfunction
