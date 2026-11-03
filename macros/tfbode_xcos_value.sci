function value = tfbode_xcos_value(expression, context)
    // Evaluate parameter expressions using Xcos-style context, not global variables.
    context.z = %z;
    [evaluated, ierr] = script2var("tfbode_parameter_value = (" + expression + ");", context);
    if ierr <> 0 then error("Cannot evaluate discrete block parameter: " + expression); end
    value = evaluated.tfbode_parameter_value;
endfunction
