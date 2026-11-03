function [H, fig] = tfbode_xcos(diagram, fmin, fmax, units, x0, u0)
    rhs = argn(2);
    if rhs < 1 | rhs == 5 then
        error("Pass a diagram, optional frequency bounds and units, and both x0 and u0 if needed.");
    end
    if rhs < 2 then fmin = 0.01; end
    if rhs < 3 then fmax = 100; end
    if rhs < 4 then units = "rad/s"; end
    loadXcosLibs();
    loadScicos();
    if typeof(diagram) == "Block" then diagram = tfbode_xcos_wrap(diagram); end
    if typeof(diagram) <> "diagram" then error("Pass an Xcos diagram or a selected block."); end
    tfbode_xcos_check(diagram);
    nin = 0; nout = 0;
    for k = 1:length(diagram.objs)
        obj = diagram.objs(k);
        if typeof(obj) == "Block" then
            if or(obj.gui == ["IN_f" "INPUTPORT"]) then nin = nin + 1; end
            if or(obj.gui == ["OUT_f" "OUTPUTPORT"]) then nout = nout + 1; end
        end
    end
    if nin <> 1 | nout < 1 then
        error("Use one IN_f input port and at least one OUT_f output port to mark the analysis path. Replace the step source and scope in an analysis copy, or select a transfer-function block instead.");
    end
    // lincos evaluates diagram context and linearizes about the specified point.
    if rhs >= 6 then
        H = lincos(diagram, x0, u0);
    elseif rhs == 5 then
        error("Supply both x0 and u0 for a custom operating point.");
    else
        H = lincos(diagram);
    end
    if size(H, 2) <> 1 then error("The analysis input must be scalar."); end
    [H, fig] = tfbode(H, fmin, fmax, units);
endfunction
