function tfbode_xcos_check(diagram)
    for k = 1:length(diagram.objs)
        obj = diagram.objs(k);
        if typeof(obj) == "Block" then
            if ~isempty(obj.model.dstate) | ~isempty(obj.model.evtin) | ~isempty(obj.model.evtout) then
                error("Diagram Bode analysis supports continuous-time signal diagrams. Remove clocked/discrete blocks and event-connected scopes from the analysis copy.");
            end
            if typeof(obj.model.rpar) == "diagram" then
                tfbode_xcos_check(obj.model.rpar);
            end
        end
    end
endfunction
