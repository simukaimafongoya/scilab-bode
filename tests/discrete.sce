root = get_absolute_file_path("discrete.sce") + "../";
try
    exec(root + "builder.sce", -1);
    exec(root + "loader.sce", -1);
    loadXcosLibs(); loadScicos();
    ts = 0.1;
    expected = syslin(ts, 1/(%z - 0.5));
    H = tfbode_system(1, [1 -0.5], ts);
    assert_checkalmostequal(repfreq(H, [0.1 1 4]), repfreq(expected, [0.1 1 4]));
    block = DLR("define");
    block.graphics.exprs = ["1"; "z-0.5"];
    [H, fig] = tfbode_xcos_discrete(block, ts);
    assert_checkalmostequal(H.dt, ts);
    assert_checkalmostequal(repfreq(H, [0.1 1 4]), repfreq(expected, [0.1 1 4]), 1e-5, 1e-7);
    xs2png(fig, root + "tests/discrete-bode-preview.png"); close(fig);
    // Actual compiled sample period scales the physical frequency response.
    [H, fig] = tfbode_xcos_discrete(block, 0.2, 0.01, 2, "Hz"); close(fig);
    assert_checkalmostequal(repfreq(H, [0.1 1]), repfreq(syslin(0.2,1/(%z-0.5)), [0.1 1]), 1e-5,1e-7);
    assert_checktrue(execstr("tfbode_xcos_discrete(block, ts, 0.01, 5, ''Hz'');", "errcatch") <> 0);
    assert_checktrue(execstr("tfbode_xcos_discrete(block, 0);", "errcatch") <> 0);
    // Two cascaded discrete blocks, with context-defined coefficients.
    diagram = tfbode_xcos_wrap(block);
    diagram.props.context = "pole = 0.5;";
    diagram.objs(2).graphics.exprs = ["1"; "z-pole"];
    [H, fig] = tfbode_xcos_discrete(diagram, ts); close(fig);
    assert_checkalmostequal(repfreq(H, [0.1 1]), repfreq(expected,[0.1 1]), 1e-5,1e-7);
    cascade = scicos_diagram();
    input = IN_f("define"); input.graphics.pout = 5;
    b1 = block; b1.graphics.pin = 5; b1.graphics.pout = 6; b1.graphics.pein = 0;
    b2 = block; b2.graphics.pin = 6; b2.graphics.pout = 7; b2.graphics.pein = 0;
    output = OUT_f("define"); output.graphics.pin = 7;
    cascade.objs = list(input,b1,b2,output, ..
        scicos_link(from=[1 1 0],to=[2 1 1]), ..
        scicos_link(from=[2 1 0],to=[3 1 1]), ..
        scicos_link(from=[3 1 0],to=[4 1 1]));
    [H, fig] = tfbode_xcos_discrete(cascade, ts); close(fig);
    assert_checkalmostequal(repfreq(H,[0.1 1]),repfreq(expected^2,[0.1 1]),1e-5,1e-7);
    // Negative feedback: G/(1+G) = 1/(z+0.5), including sum and split blocks.
    feedback = scicos_diagram();
    input = IN_f("define"); input.graphics.pout = 6;
    sumblock = SUMMATION("define"); sumblock.graphics.pin = [6;10]; sumblock.graphics.pout = 7;
    plant = block; plant.graphics.pin = 7; plant.graphics.pout = 8; plant.graphics.pein = 0;
    split = SPLIT_f("define"); split.graphics.pin = 8; split.graphics.pout = [9;10];
    output = OUT_f("define"); output.graphics.pin = 9;
    feedback.objs = list(input,sumblock,plant,split,output, ..
        scicos_link(from=[1 1 0],to=[2 1 1]), ..
        scicos_link(from=[2 1 0],to=[3 1 1]), ..
        scicos_link(from=[3 1 0],to=[4 1 1]), ..
        scicos_link(from=[4 1 0],to=[5 1 1]), ..
        scicos_link(from=[4 2 0],to=[2 2 1]));
    [H, fig] = tfbode_xcos_discrete(feedback,ts); close(fig);
    assert_checkalmostequal(repfreq(H,[0.1 1]),repfreq(syslin(ts,1/(%z+0.5)),[0.1 1]),1e-5,1e-7);
    gained = cascade;
    gain = GAINBLK_f("define"); gain.graphics.exprs = "2";
    gain.graphics.pin = 6; gain.graphics.pout = 7;
    gained.objs(3) = gain;
    [H, fig] = tfbode_xcos_discrete(gained,ts); close(fig);
    assert_checkalmostequal(repfreq(H,[0.1 1]),repfreq(2*expected,[0.1 1]),1e-5,1e-7);
    // State-space and one-sample delay blocks.
    ss = DLSS("define"); ss.graphics.exprs = ["0.5";"1";"1";"0";"0"];
    [H, fig] = tfbode_xcos_discrete(ss,ts); close(fig);
    assert_checkalmostequal(repfreq(H,[0.1 1]),repfreq(expected,[0.1 1]),1e-5,1e-7);
    delay = DOLLAR_m("define");
    [H, fig] = tfbode_xcos_discrete(delay,ts); close(fig);
    assert_checkalmostequal(repfreq(H,[0.1 1]),repfreq(syslin(ts,1/%z),[0.1 1]),1e-5,1e-7);
    // Reject a mixed diagram rather than quietly interpreting continuous states as delays.
    mixed = cascade; mixed.objs(3) = CLR("define");
    assert_checktrue(execstr("tfbode_xcos_discrete(mixed,ts);", "errcatch") <> 0);
    event = diagram;
    clock = CLOCK_c("define"); clock.graphics.peout = 7;
    event.objs(2).graphics.pein = 7;
    event.objs(6) = clock;
    event.objs(7) = scicos_link(ct=[5 -1],from=[6 1 0],to=[2 1 1]);
    assert_checktrue(execstr("tfbode_xcos_discrete(event,ts);", "errcatch") <> 0);
    mputl("PASS: discrete coefficients, DLR, DLSS, delay, cascade, feedback, gain, context, sample-time scaling, Nyquist and unsupported diagram checks", root + "tests/discrete-result.log");
catch
    mputl(lasterror(), root + "tests/discrete-result.log");
    exit(1);
end
exit(0);
