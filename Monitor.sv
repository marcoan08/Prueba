`ifndef ROUTER_MONITOR_SV
`define ROUTER_MONITOR_SV

class router_monitor extends uvm_monitor;
    `uvm_component_utils(router_monitor)
    
    // Virtual interface
    virtual router_if vif;
    
    // Terminal ID (0-3)
    int terminal_id;
    
    // Analysis port for sending transactions to scoreboard
    uvm_analysis_port #(router_item) item_collected_port;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual router_if)::get(this, "", $sformatf("vif%0d", terminal_id), vif)) begin
            `uvm_fatal("NOVIF", $sformatf("No virtual interface specified for terminal %0d", terminal_id))
        end
    endfunction
    
    task run_phase(uvm_phase phase);
        router_item item;
        
        // Wait for reset to complete
        @(negedge vif.sync_reset);
        
        forever begin
            // Monitor for incoming packets (pndng_i_in and pop)
            if (vif.monitor_cb.pndng_i_in && vif.monitor_cb.popin) begin
                item = router_item::type_id::create("item");
                item.unpack(vif.monitor_cb.data_out_i_in);
                item.is_response = 0; // This is a sent packet
                
                `uvm_info("MONITOR", $sformatf("Terminal %0d monitored sent packet: %s", terminal_id, item.convert2string()), UVM_HIGH)
                
                item_collected_port.write(item);
            end
            
            // Monitor for outgoing packets (pndng and pop)
            if (vif.monitor_cb.pndng && vif.monitor_cb.pop) begin
                item = router_item::type_id::create("item");
                item.unpack(vif.monitor_cb.data_out);
                item.is_response = 1; // This is a received packet
                
                `uvm_info("MONITOR", $sformatf("Terminal %0d monitored received packet: %s", terminal_id, item.convert2string()), UVM_HIGH)
                
                item_collected_port.write(item);
            end
            
            @(vif.monitor_cb);
        end
    endtask
endclass

`endif // ROUTER_MONITOR_SV