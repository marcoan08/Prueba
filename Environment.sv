class env #(
    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter fifo_depth = 4,
    parameter columns = 4,
    parameter rows = 4,
    parameter id_c = 0,
    parameter id_r = 0
) extends uvm_env;

    `uvm_component_param_utils(env #(
        pckg_sz, num_ntrfs, broadcast, fifo_depth, columns, rows, id_c, id_r
    ))

    agent #(
        .pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast), .fifo_depth(fifo_depth), .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r)
    ) agt]; //un solo agente

    scoreboard #(
        .pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast), .fifo_depth(fifo_depth), .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r)
    ) scb;

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Crear múltiples agentes, uno por terminal
        //for (int i = 0; i < num_ntrfs; i++) begin
            //string agt_name;
            //$sformat(agt_name, "agt_%0d", i);
            //uvm_config_db#(int)::set(this, agt_name, "terminal_id", i);
            agt = agent#(pckg_sz, num_ntrfs, broadcast, fifo_depth, columns, rows, id_c, id_r)::type_id::create(agt_name, this);
            if (agt == null) begin
                `uvm_fatal("ENV", $sformatf("Failed to create agent"))
            end
        //end

        scb = scoreboard#(pckg_sz, num_ntrfs, broadcast, fifo_depth, columns, rows, id_c, id_r)::type_id::create("scb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        //for (int i = 0; i < num_ntrfs; i++) begin
            agt.analysis_port.connect(scb.m_analysis_imp);
            agt.expected_item_port.connect(scb.expected_items_imp);
        //end
    endfunction

endclass