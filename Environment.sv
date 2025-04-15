`ifndef ROUTER_ENV_SV
`define ROUTER_ENV_SV

class router_env extends uvm_env;
    `uvm_component_utils(router_env)
    
    // Agents for each terminal
    router_agent agents[4];
    
    // Scoreboard
    router_scoreboard scoreboard;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create agents for each terminal
        foreach (agents[i]) begin
            agents[i] = router_agent::type_id::create($sformatf("agent%0d", i), this);
            uvm_config_db#(int)::set(this, $sformatf("agent%0d*", i), "terminal_id", i);
        end
        
        // Create scoreboard
        scoreboard = router_scoreboard::type_id::create("scoreboard", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect all agent monitors to scoreboard
        foreach (agents[i]) begin
            agents[i].monitor.item_collected_port.connect(scoreboard.sb_export[i]);
            
            // Connect drivers too (they also send to scoreboard)
            if (agents[i].get_is_active() == UVM_ACTIVE) begin
                agents[i].driver.item_collected_port.connect(scoreboard.sb_export[i]);
            end
        end
    endfunction
endclass

`endif // ROUTER_ENV_SV