function tfbode_xcos_menu(target, context)
    rhs = argn(2);
    defaults = ["0.01"; "100"; "rad/s"];
    try
        answer = x_mdialog(["Xcos Bode analysis"; ..
            "Continuous systems; linearization about zero state and input"], ..
            ["Minimum frequency"; "Maximum frequency"; "Units: rad/s or Hz"], defaults);
        if isempty(answer) then return; end
        if typeof(target) == "Block" then
            loadXcosLibs(); loadScicos();
            target = tfbode_xcos_wrap(target);
            if rhs >= 2 then
                target.props.context = [context; target.props.context];
            end
        end
        tfbode_xcos(target, tfbode_numbers(answer(1)), ..
            tfbode_numbers(answer(2)), answer(3));
    catch
        messagebox(lasterror(), "Xcos Bode analysis", "error", "modal");
    end
endfunction
