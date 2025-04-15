`ifndef ROUTER_SCOREBOARD_SV
`define ROUTER_SCOREBOARD_SV

class router_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(router_scoreboard)
    
    // Analysis ports from all monitors and drivers
    uvm_analysis_export #(router_item) sb_export[4];
    
    // FIFOs to store transactions from each terminal
    uvm_tlm_analysis_fifo #(router_item) terminal_fifo[4];
    
    // Expected packets queue
    router_item expected_packets[$];
    
    // Statistics
    int packets_sent = 0;
    int packets_received = 0;
    int mismatches = 0;
    int broadcast_packets = 0;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        foreach (sb_export[i]) begin
            sb_export[i] = new($sformatf("sb_export%0d", i), this);
        end
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        foreach (terminal_fifo[i]) begin
            terminal_fifo[i] = new($sformatf("terminal_fifo%0d", i), this);
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        foreach (sb_export[i]) begin
            sb_export[i].connect(terminal_fifo[i].analysis_export);
        end
    endfunction
    
    task run_phase(uvm_phase phase);
        router_item item;
        
        forever begin
            // Check all FIFOs for new transactions
            foreach (terminal_fifo[i]) begin
                if (terminal_fifo[i].try_get(item)) begin
                    process_item(item, i);
                end
            end
            #10; // Small delay to prevent tight loop
        end
    endtask
    
    function void process_item(router_item item, int terminal_id);
        if (item.is_response) begin
            // This is a received packet
            packets_received++;
            
            // Check if this packet was expected
            if (expected_packets.size() > 0) begin
                router_item expected = expected_packets.pop_front();
                
                // Compare received packet with expected
                if (!compare_packets(item, expected)) begin
                    `uvm_error("SCOREBOARD", $sformatf("Packet mismatch!\nReceived: %s\nExpected: %s", 
                                                      item.convert2string(), expected.convert2string()))
                    mismatches++;
                end else begin
                    `uvm_info("SCOREBOARD", $sformatf("Packet matched for terminal %0d: %s", 
                                                     terminal_id, item.convert2string()), UVM_HIGH)
                end
            end else begin
                `uvm_error("SCOREBOARD", $sformatf("Unexpected packet received on terminal %0d: %s", 
                                                  terminal_id, item.convert2string()))
                mismatches++;
            end
        end else begin
            // This is a sent packet
            packets_sent++;
            
            // For broadcast packets, we expect them to be received by all other terminals
            if (item.target_id == 4) begin // Broadcast ID
                broadcast_packets++;
                for (int i = 0; i < 4; i++) begin
                    if (i != terminal_id) begin // Don't expect to receive on sending terminal
                        router_item expected = item.copy();
                        expected.is_response = 1;
                        expected_packets.push_back(expected);
                    end
                end
            end else begin
                // For unicast packets, expect them to be received by the target terminal
                router_item expected = item.copy();
                expected.is_response = 1;
                expected_packets.push_back(expected);
            end
        end
    endfunction
    
    // Compare two packets (ignore delay and is_response fields)
    function bit compare_packets(router_item a, router_item b);
        return (a.target_id  == b.target_id)  &&
               (a.target_row == b.target_row) &&
               (a.target_col == b.target_col) &&
               (a.mode       == b.mode)      &&
               (a.source_id  == b.source_id)  &&
               (a.packet_id  == b.packet_id)  &&
               (a.payload    == b.payload);
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", $sformatf("\n\n--- TEST SUMMARY ---\nPackets Sent:     %0d\nPackets Received: %0d\nBroadcast Packets: %0d\nMismatches:       %0d\n",
                                         packets_sent, packets_received, broadcast_packets, mismatches), UVM_LOW)
    endfunction
endclass

`endif // ROUTER_SCOREBOARD_SV