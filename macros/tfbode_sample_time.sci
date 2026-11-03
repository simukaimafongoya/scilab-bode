function tfbode_sample_time(sample_time)
    if type(sample_time) <> 1 then error("Sample period must be a number in seconds."); end
    if size(sample_time, "*") <> 1 | ~isreal(sample_time) then
        error("Sample period must be a real scalar in seconds.");
    end
    if isnan(sample_time) | isinf(sample_time) | sample_time <= 0 then
        error("Sample period must be finite and strictly positive.");
    end
endfunction
