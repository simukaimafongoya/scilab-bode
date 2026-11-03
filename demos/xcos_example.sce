root = get_absolute_file_path("xcos_example.sce") + "../";
exec(root + "loader.sce", -1);
loadXcosLibs(); loadScicos();
// Build IN_f -> transfer function 1/(s+1) -> OUT_f.
scs_m = tfbode_xcos_wrap(CLR("define"));
xcos(scs_m);
// In Xcos: Tools > Bode plot of diagram.
