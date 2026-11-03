root = get_absolute_file_path("package.sce") + "../";
try
    load("SCI/modules/atoms/macros/atoms_internals/lib");
    extracted = atomsExtract(root + "dist/tfbode-0.3.0-scilab-2026.1.zip", TMPDIR);
    folder = TMPDIR + filesep() + extracted + filesep();
    description = atomsDESCRIPTIONread(folder + "DESCRIPTION");
    assert_checkequal(description.packages.tfbode("0.3.0").Toolbox, "tfbode");
    exec(folder + "loader.sce", -1);
    H = tfbode_system(10, [1 2 10]);
    [H, fig] = tfbode(H, 0.01, 100, "rad/s");
    close(fig);
    mputl("PASS: ATOMS archive extraction, DESCRIPTION parsing, relocated loader and plotting", root + "tests/package-result.log");
catch
    mputl(lasterror(), root + "tests/package-result.log");
    exit(1);
end
exit(0);

