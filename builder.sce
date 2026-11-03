// Build the pure-Scilab ATOMS toolbox; no C compiler is required.
function build_tfbode()
    root = get_absolute_file_path("builder.sce");
    tbx_builder_macros(root);
    tbx_build_loader(root);
    tbx_build_cleaner(root);
endfunction
build_tfbode();
clear build_tfbode;
