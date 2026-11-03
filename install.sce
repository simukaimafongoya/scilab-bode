// Run once from a source checkout. Builds locally and loads this session.
tfbode_root = get_absolute_file_path("install.sce");
exec(tfbode_root + "builder.sce", -1);
exec(tfbode_root + "loader.sce", -1);
clear tfbode_root;
mprintf("TFBode loaded. Type tfbode() or use the Xcos Tools menu.\n");
