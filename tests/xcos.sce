root = get_absolute_file_path("xcos.sce") + "../";
try
    exec(root + "builder.sce", -1);
    exec(root + "loader.sce", -1);
    loadXcosLibs(); loadScicos();
    block = CLR("define");
    diagram = tfbode_xcos_wrap(block);
    [H, fig] = tfbode_xcos(diagram, 0.01, 100, "rad/s");
    // Compare the diagram linearization against the known 1/(s+1).
    expected = syslin("c", 1 / (%s + 1));
    assert_checkalmostequal(repfreq(H, [0.01 0.1 1 10]), ..
        repfreq(expected, [0.01 0.1 1 10]), 1e-5, 1e-7);
    xs2png(fig, root + "tests/xcos-bode-preview.png"); close(fig);
    [H, fig] = tfbode_xcos(block, 0.01, 100, "Hz"); close(fig);
    assert_checktrue(execstr("tfbode_xcos(scicos_diagram());", "errcatch") <> 0);
    // Two cascaded dynamic blocks exercise whole-diagram connectivity.
    cascade = scicos_diagram();
    input = IN_f("define"); input.graphics.pout = 5;
    b1 = block; b1.graphics.pin = 5; b1.graphics.pout = 6;
    b2 = block; b2.graphics.pin = 6; b2.graphics.pout = 7;
    output = OUT_f("define"); output.graphics.pin = 7;
    cascade.objs = list(input, b1, b2, output, ..
        scicos_link(from=[1 1 0], to=[2 1 1]), ..
        scicos_link(from=[2 1 0], to=[3 1 1]), ..
        scicos_link(from=[3 1 0], to=[4 1 1]));
    [H, fig] = tfbode_xcos(cascade); close(fig);
    assert_checkalmostequal(repfreq(H, [0.1 1]), ..
        repfreq(expected^2, [0.1 1]), 1e-5, 1e-7);
    bad = diagram; bad.objs(2).model.dstate = 0;
    assert_checktrue(execstr("tfbode_xcos(bad);", "errcatch") <> 0);
    // Context expressions must work without opening parameter dialogs.
    diagram.props.context = "tau = 2;";
    diagram.objs(2).graphics.exprs = ["1"; "1+tau*s"];
    [H, fig] = tfbode_xcos(diagram); close(fig);
    assert_checkalmostequal(repfreq(H, [0.1 1]), ..
        repfreq(syslin("c", 1/(2*%s+1)), [0.1 1]), 1e-5, 1e-7);
    // Exercise Xcos export as a reusable diagram file.
    scs_m = tfbode_xcos_wrap(block);
    save(root + "demos/bode-example.cos", "scs_m");
    xcosDiagramExport(scs_m, root + "tests/xcos-diagram.png");
    mputl("PASS: Xcos menu registration, diagram and block analysis, analytical response, context, export", root + "tests/xcos-result.log");
catch
    mputl(lasterror(), root + "tests/xcos-result.log");
    exit(1);
end
exit(0);
