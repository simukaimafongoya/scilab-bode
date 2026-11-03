root = get_absolute_file_path("discrete_example.sce") + "../";
exec(root + "loader.sce", -1);
loadXcosLibs(); loadScicos();
// Sample period 0.1 seconds; G(z) = 1/(z - 0.5).
block = DLR("define");
block.graphics.exprs = ["1"; "z-0.5"];
scs_m = tfbode_xcos_wrap(block);
tfbode_xcos_discrete(scs_m, 0.1, 0.01, 4, "Hz");
xcos(scs_m);
// Tools > Bode plot of diagram: sample period 0.1, max frequency blank (auto).
