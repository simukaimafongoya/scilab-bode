function tfbode_xcos_menu(target, context)
    rhs = argn(2);
    defaults = ["0.01"; ""; "rad/s"; "0"];
    try
        answer = x_mdialog(["Xcos Bode analysis"; ..
            "Continuous or single-rate discrete linear systems"], ..
            ["Minimum frequency"; "Maximum frequency (blank = automatic)"; ..
             "Units: rad/s or Hz"; "Sample period in seconds: 0 = continuous"], defaults);
        if isempty(answer) then return; end
        if typeof(target) == "Block" then
            loadXcosLibs(); loadScicos();
            target = tfbode_xcos_wrap(target);
            if rhs >= 2 then
                target.props.context = [context; target.props.context];
            end
        end
        ts = tfbode_numbers(answer(4));
        if size(ts,"*") <> 1 then error("Sample period must be a scalar."); end
        if stripblanks(answer(2)) == "" then
            hi = 100;
            if ts <> 0 then
                tfbode_sample_time(ts);
                hi = 0.45 / ts;
                if convstr(stripblanks(answer(3)), "l") == "rad/s" then hi = hi * 2 * %pi; end
            end
        else
            hi = tfbode_numbers(answer(2));
        end
        if ts == 0 then
            tfbode_xcos(target, tfbode_numbers(answer(1)), hi, answer(3));
        else
            tfbode_xcos_discrete(target, ts, tfbode_numbers(answer(1)), hi, answer(3));
        end
    catch
        messagebox(lasterror(), "Xcos Bode analysis", "error", "modal");
    end
endfunction
