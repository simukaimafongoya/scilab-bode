root = get_absolute_file_path("run.sce") + "../";
try
    exec(root + "builder.sce", -1);
    exec(root + "loader.sce", -1);
    H = tfbode_system([10], [1 2 10]);
    assert_checkalmostequal(coeff(H.num), 10);
    assert_checkalmostequal(coeff(H.den), [10 2 1]);
    assert_checkalmostequal(tfbode_numbers("[1, -2.5, 3e-2]"), [1 -2.5 0.03]);
    assert_checktrue(execstr("tfbode_numbers(''1 garbage'');", "errcatch") <> 0);
    assert_checktrue(execstr("tfbode_system(1, [0 0]);", "errcatch") <> 0);
    assert_checktrue(execstr("tfbode_system(0, [1 1]);", "errcatch") <> 0);
    assert_checktrue(execstr("tfbode(H, 10, 1);", "errcatch") <> 0);
    assert_checktrue(execstr("tfbode(H, 0, 10);", "errcatch") <> 0);
    assert_checktrue(execstr("tfbode(H, 1, 10, ''rpm'');", "errcatch") <> 0);
    assert_checktrue(execstr("tfbode([H H]);", "errcatch") <> 0);
    U = H; U.dt = [];
    assert_checktrue(execstr("tfbode(U);", "errcatch") <> 0);
    U.dt = -1;
    assert_checktrue(execstr("tfbode(U);", "errcatch") <> 0);
    D = syslin(0.1, 1 / (%z - 0.5));
    assert_checktrue(execstr("tfbode(D, 0.1, 5, ''Hz'');", "errcatch") <> 0);
    // Real graphics smoke test: both units and a sampled system.
    [out, fig] = tfbode(H, 0.01, 100, "rad/s");
    xs2png(fig, root + "tests/bode-preview.png");
    close(fig);
    [out, fig] = tfbode(H, 0.01, 10, "Hz");
    close(fig);
    [out, fig] = tfbode(D, 0.1, 4, "Hz");
    close(fig);
    mputl("PASS: build, load, coefficient conversion, validation, rad/s, Hz and discrete plotting", root + "tests/result.log");
catch
    mputl(lasterror(), root + "tests/result.log");
    exit(1);
end
exit(0);
