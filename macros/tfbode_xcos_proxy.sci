function [diagram, count] = tfbode_xcos_proxy(diagram, context)
    // Replace each supported discrete state update by the same continuous A/B/C/D
    // equations. lincos composes these matrices; the caller restores discrete dt.
    // This is an algebraic state-space construction, not continuous discretization.
    [context, ierr] = script2var(diagram.props.context, context);
    if ierr <> 0 then error("Cannot evaluate diagram context."); end
    diagram.props.context = [];
    count = 0;
    for k = 1:length(diagram.objs)
        obj = diagram.objs(k);
        if typeof(obj) == "Link" then
            if obj.ct(2) <> 1 then
                error("Discrete diagram analysis requires signal links only. Remove clocks and event wiring in an analysis copy, or analyze a selected discrete block.");
            end
        elseif typeof(obj) == "Block" then
            if or(obj.model.intyp > 1) | or(obj.model.outtyp > 1) then
                error("Discrete Bode analysis supports real floating-point signals only.");
            end
            if typeof(obj.model.rpar) == "diagram" then
                if ~isempty(obj.model.evtin) | ~isempty(obj.model.evtout) then
                    error("Remove clock/event superblocks from the discrete analysis copy.");
                end
                [obj.model.rpar, nested] = tfbode_xcos_proxy(obj.model.rpar, context);
                count = count + nested;
            elseif or(obj.gui == ["DLR" "DLSS" "DOLLAR_m" "DOLLAR_f"]) then
                exprs = obj.graphics.exprs;
                if obj.gui == "DLR" then
                    num = tfbode_xcos_value(exprs(1), context);
                    den = tfbode_xcos_value(exprs(2), context);
                    if ~or(type(num) == [1 2]) | ~or(type(den) == [1 2]) then
                        error("DLR numerator and denominator must be polynomials.");
                    end
                    if size(num,"*") <> 1 | size(den,"*") <> 1 then error("DLR must be SISO."); end
                    num = poly(coeff(num), "s", "coeff");
                    den = poly(coeff(den), "s", "coeff");
                    if den == 0 then error("DLR denominator cannot be zero."); end
                    if degree(num) > degree(den) then error("DLR transfer function must be proper."); end
                    system = cont_frm(num, den);
                    [A,B,C,D] = system(2:5);
                elseif obj.gui == "DLSS" then
                    A = tfbode_xcos_value(exprs(1), context);
                    B = tfbode_xcos_value(exprs(2), context);
                    C = tfbode_xcos_value(exprs(3), context);
                    D = tfbode_xcos_value(exprs(4), context);
                    // syslin validates compatible matrix dimensions.
                    system = syslin("c", A, B, C, D);
                    [A,B,C,D] = system(2:5);
                else
                    initial = tfbode_xcos_value(exprs(1), context);
                    if type(initial) <> 1 | ~isreal(initial) then error("Unit delays require real floating-point states."); end
                    if size(initial,"*") <> 1 then error("Only scalar unit-delay blocks are supported."); end
                    A = 0; B = 1; C = 1; D = 0;
                end
                for matrix_value = list(A,B,C,D)
                    if ~isreal(matrix_value) | or(isnan(matrix_value)) | or(isinf(matrix_value)) then
                        error("Discrete state-space matrices must be finite and real.");
                    end
                end
                // CLR/CLSS parameter expressions are evaluated again by lincos.
                obj.gui = "CLSS";
                obj.model.sim = list("csslti4", 4);
                obj.model.state = zeros(size(A,1), 1);
                obj.model.dstate = [];
                obj.model.odstate = list();
                obj.model.evtin = []; obj.model.evtout = [];
                obj.model.blocktype = "c";
                obj.model.dep_ut = [norm(D,1) <> 0 %t];
                obj.graphics.pein = []; obj.graphics.peout = [];
                obj.graphics.exprs = [sci2exp(A); sci2exp(B); sci2exp(C); sci2exp(D); sci2exp(zeros(size(A,1),1))];
                obj.model.rpar = [A(:); B(:); C(:); D(:)];
                count = count + 1;
            elseif or(obj.gui == ["IN_f" "INPUTPORT" "OUT_f" "OUTPUTPORT" ..
                    "GAINBLK" "GAINBLK_f" "SUMMATION" "SUM_f" "BIGSOM_f" "SPLIT_f"]) then
                // Freeze expressions in their scope before clearing diagram context.
                expressions = obj.graphics.exprs;
                for j = 1:size(expressions,"*")
                    expressions(j) = sci2exp(tfbode_xcos_value(expressions(j), context));
                end
                obj.graphics.exprs = expressions;
            else
                error("Unsupported block in discrete analysis: " + obj.gui + ". Use DLR, DLSS, scalar unit delays, gains, sums, splits and I/O ports. Mixed continuous/discrete diagrams are unsupported.");
            end
            diagram.objs(k) = obj;
        end
    end
endfunction
