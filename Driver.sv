`ifndef ROUTER_DRIVER_SV
`define ROUTER_DRIVER_SV

class router_driver extends uvm_driver #(router_item);
    `uvm_component_utils(router_driver)
    
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
        router_item req;
        router_item rsp;
        
        // Initialize signals
        vif.driver_cb.data_out_i_in <= 0;
        vif.driver_cb.pndng_i_in <= 0;
        vif.driver_cb.pop <= 0;
        
        // Wait for reset to complete
        @(negedge vif.sync_reset);
        
        forever begin
            seq_item_port.get_next_item(req);
            
            `uvm_info("DRIVER", $sformatf("Terminal %0d driving packet: %s", terminal_id, req.convert2string()), UVM_HIGH)
            
            // Apply delay if specified
            if (req.delay > 0) begin
                repeat(req.delay) @(vif.driver_cb);
            end
            
            // Drive packet onto interface
            vif.driver_cb.data_out_i_in <= req.pack();
            vif.driver_cb.pndng_i_in <= 1;
            
            // Wait for router to accept the packet
            do begin
                @(vif.driver_cb);
            end while (vif.driver_cb.popin != 1);
            
            vif.driver_cb.pndng_i_in <= 0;
            
            // Send received packet to scoreboard
            item_collected_port.write(req);
            
            // Check if we need to pop a response
            if (vif.driver_cb.pndng) begin
                `uvm_info("DRIVER", $sformatf("Terminal %0d detected pending data", terminal_id), UVM_HIGH)
                
                vif.driver_cb.pop <= 1;
                @(vif.driver_cb);
                vif.driver_cb.pop <= 0;
                
                // Create response item
                rsp = router_item::type_id::create("rsp");
                rsp.unpack(vif.driver_cb.data_out);
                rsp.is_response = 1;
                
                `uvm_info("DRIVER", $sformatf("Terminal %0d received response: %s", terminal_id, rsp.convert2string()), UVM_HIGH)
                
                // Send response to scoreboard
                item_collected_port.write(rsp);
            end
            
            seq_item_port.item_done();
        end
    endtask
endclass

`endif // ROUTER_DRIVER_SV