function diagram = tfbode_xcos_wrap(block)
    // Isolate a selected scalar-input/scalar-output block for linearization.
    if typeof(block) <> "Block" then error("Select one Xcos block first."); end
    if typeof(block.model.rpar) == "diagram" then
        if ~isempty(block.model.evtin) | ~isempty(block.model.evtout) then
            error("Event-driven superblocks are not supported by continuous Bode analysis.");
        end
        diagram = block.model.rpar;
        return;
    end
    if size(block.model.in, "*") <> 1 | size(block.model.out, "*") <> 1 then
        error("Select a block with one signal input and one signal output, or a superblock.");
    end
    if ~isempty(block.model.evtin) | ~isempty(block.model.evtout) then
        error("Event-driven blocks are not supported by continuous Bode analysis.");
    end
    diagram = scicos_diagram();
    diagram.props.title = ["Bode analysis"; ""];
    input = IN_f("define");
    output = OUT_f("define");
    input.graphics.orig = [0 0]; input.graphics.pout = 4;
    block.graphics.orig = [60 0];
    block.graphics.pin = 4; block.graphics.pout = 5;
    output.graphics.orig = [140 0]; output.graphics.pin = 5;
    diagram.objs(1) = input;
    diagram.objs(2) = block;
    diagram.objs(3) = output;
    diagram.objs(4) = scicos_link(xx=[20;60], yy=[10;10], ..
        from=[1 1 0], to=[2 1 1]);
    diagram.objs(5) = scicos_link(xx=[80;140], yy=[10;10], ..
        from=[2 1 0], to=[3 1 1]);
endfunction
