function [H, fig] = tfbode(H, fmin, fmax, units)
    // tfbode() opens coefficient entry. tfbode(H, lo, hi, units) plots H.
    rhs = argn(2);
    fig = [];
    if rhs == 0 then
        H = [];
        defaults = ["1"; "1 2 1"; "0.01"; "100"; "rad/s"];
        while %t
            answer = x_mdialog(["Transfer-function Bode plot"; ..
                "Coefficients in descending powers of s (e.g. 1 2 1 = s^2+2s+1)"], ..
                ["Numerator coefficients"; "Denominator coefficients"; ..
                 "Minimum frequency (> 0)"; "Maximum frequency"; "Units: rad/s or Hz"], defaults);
            if isempty(answer) then H = []; return; end
            defaults = answer;
            try
                num = tfbode_numbers(answer(1));
                den = tfbode_numbers(answer(2));
                lo = tfbode_numbers(answer(3));
                hi = tfbode_numbers(answer(4));
                H = tfbode_system(num, den);
                [H, fig] = tfbode(H, lo, hi, answer(5));
                return;
            catch
                messagebox(lasterror(), "Bode plot: check input", "error", "modal");
            end
        end
    end
    if rhs < 2 then fmin = 0.01; end
    if rhs < 3 then fmax = 100; end
    if rhs < 4 then units = "rad/s"; end
    if type(units) <> 10 | size(units, "*") <> 1 then
        error("Units must be rad/s or Hz.");
    end
    units = convstr(stripblanks(units), "l");
    if units <> "rad/s" & units <> "hz" then
        error("Units must be rad/s or Hz.");
    end
    for bound = list(fmin, fmax)
        if type(bound) <> 1 then error("Frequency bounds must be numeric scalars."); end
        if size(bound, "*") <> 1 | ~isreal(bound) then
            error("Frequency bounds must be real scalars.");
        end
        if isnan(bound) | isinf(bound) | bound <= 0 then
            error("Frequency bounds must be finite and positive.");
        end
    end
    if fmax <= fmin then error("Maximum frequency must exceed minimum frequency."); end
    if ~or(typeof(H) == ["rational" "state-space" "zpk"]) then
        error("Pass a syslin/zpk system, or use tfbode_system(num, den).");
    end
    if size(H, 2) <> 1 then error("Bode plotting requires one input (SISO or SIMO)."); end
    // Scilab bode() ALWAYS takes frequencies in Hz, including with its rad option.
    loHz = fmin; hiHz = fmax;
    if units == "rad/s" then
        loHz = fmin / (2 * %pi); hiHz = fmax / (2 * %pi);
    end
    dt = H.dt;
    if isempty(dt) then error("Specify the system time domain with syslin first."); end
    if type(dt) == 1 then
        if size(dt, "*") <> 1 | ~isreal(dt) then error("Sample period must be a real scalar."); end
        if isnan(dt) | isinf(dt) | dt <= 0 then error("Sample period must be finite and positive."); end
        if hiHz >= 1 / (2 * dt) then
            error("Maximum frequency must be below the discrete system Nyquist frequency.");
        end
    elseif dt == "d" then
        if hiHz >= 0.5 then
            error("For an unspecified discrete sample time, maximum frequency must be below 0.5 Hz (pi rad/sample).");
        end
    elseif dt <> "c" then
        error("The system must have a continuous or discrete time domain.");
    end
    fig = scf();
    fig.figure_name = "Transfer-function Bode plot";
    try
        if units == "rad/s" then
            bode(H, loHz, hiHz, "rad");
        else
            bode(H, loHz, hiHz);
        end
    catch
        msg = lasterror();
        close(fig);
        fig = [];
        error(msg);
    end
endfunction
