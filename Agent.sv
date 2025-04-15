`ifndef ROUTER_AGENT_SV
`define ROUTER_AGENT_SV

class router_agent extends uvm_agent;
    `uvm_component_utils(router_agent)
    
    // Components
    router_driver    driver;
    router_monitor   monitor;
    uvm_sequencer #(router_item) sequencer;
    
    // Terminal ID (0-3)
    int terminal_id;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get terminal ID from config
        if (!uvm_config_db#(int)::get(this, "", "terminal_id", terminal_id)) begin
            `uvm_fatal("NO_TERMINAL_ID", "Terminal ID not specified for agent")
        end
        
        monitor = router_monitor::type_id::create("monitor", this);
        monitor.terminal_id = terminal_id;
        
        // Only build sequencer and driver for active agents
        if (get_is_active() == UVM_ACTIVE) begin
            sequencer = uvm_sequencer#(router_item)::type_id::create("sequencer", this);
            driver = router_driver::type_id::create("driver", this);
            driver.terminal_id = terminal_id;
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass

`endif // ROUTER_AGENT_SV