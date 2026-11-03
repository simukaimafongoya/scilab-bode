function tfbode_xcos_setup()
    global %tfbode_xcos_registered;
    if isempty(%tfbode_xcos_registered) then
        xcosAddToolsMenu("Bode plot of diagram", "tfbode_xcos_menu(scs_m)");
        xcosAddToolsMenu("Bode plot of selected block", ..
            "if exists(''blk'') then tfbode_xcos_menu(blk, scs_m.props.context); else messagebox(''Select one block first.'', ''Bode analysis''); end");
        %tfbode_xcos_registered = %t;
    end
endfunction
