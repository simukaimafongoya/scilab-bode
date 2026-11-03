function [H, fig] = tfbode_xcos_discrete(diagram, sample_time, fmin, fmax, units)
    rhs = argn(2);
    if rhs < 2 then error("Pass a diagram/block and its sample period in seconds."); end
    tfbode_sample_time(sample_time);
    if rhs < 5 then units = "rad/s"; end
    if type(units) <> 10 | size(units,"*") <> 1 then error("Units must be rad/s or Hz."); end
    units = convstr(stripblanks(units), "l");
    if units <> "rad/s" & units <> "hz" then error("Units must be rad/s or Hz."); end
    upper = 0.45 / sample_time;
    if units == "rad/s" then upper = upper * 2 * %pi; end
    if rhs < 4 then fmax = upper; end
    if rhs < 3 then fmin = fmax / 10000; end
    loadXcosLibs(); loadScicos();
    if typeof(diagram) == "Block" then diagram = tfbode_xcos_wrap(diagram); end
    if typeof(diagram) <> "diagram" then error("Pass an Xcos diagram or a selected discrete block."); end
    [proxy, count] = tfbode_xcos_proxy(diagram, struct());
    if count == 0 then error("No supported discrete blocks were found in the diagram."); end
    // Call lincos directly to avoid an intermediate continuous Bode figure.
    nin = 0; nout = 0;
    for k = 1:length(proxy.objs)
        obj = proxy.objs(k);
        if typeof(obj) == "Block" then
            if or(obj.gui == ["IN_f" "INPUTPORT"]) then nin = nin + 1; end
            if or(obj.gui == ["OUT_f" "OUTPUTPORT"]) then nout = nout + 1; end
        end
    end
    if nin <> 1 | nout < 1 then error("Use one IN_f input and at least one OUT_f output."); end
    H = lincos(proxy);
    H.dt = sample_time;
    [H, fig] = tfbode(H, fmin, fmax, units);
endfunction
