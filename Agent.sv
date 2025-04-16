class agent #(
    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter fifo_depth = 4,
    parameter columns = 4,
    parameter rows = 4,
    parameter id_c = 0,
    parameter id_r = 0
) extends uvm_agent;

    `uvm_component_param_utils(agent #(
        .pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast), .fifo_depth(fifo_depth), .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r)
    ))

    uvm_sequencer #(Item) s0;
    driver #(
        .pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast), .fifo_depth(fifo_depth), .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r)
    ) d0;
    monitor #(
        .pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast), .fifo_depth(fifo_depth), .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r)
    ) m0;

    uvm_analysis_port #(Item) analysis_port;        // Sale del monitor (recibido del DUT)
    uvm_analysis_port #(Item) expected_item_port;   // Sale del monitor (esperado desde el driver)

    virtual bus_if #(.num_ntrfs(num_ntrfs), .pckg_sz(pckg_sz), .broadcast(broadcast), .id_c(id_c), .id_r(id_r), .columns(columns), .rows(rows))vif; //puntero para la interfaz

    //int terminal_ID;
    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);          // Recibido desde DUT
        expected_item_port = new("expected_item_port", this); // Esperado desde driver
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //Paso el ID
        //if (!uvm_config_db#(int)::get(this, "", "terminal_id", terminal_ID))
        //`uvm_fatal("AGT", "No se pudo obtener terminal_id del config_db")
        
        //uvm_config_db#(int)::set(this, "d0", "terminal_id", terminal_ID);
        //uvm_config_db#(int)::set(this, "m0", "terminal_id", terminal_ID);
        //Creo el driver y monitor, acá tengo que poner lo del ID 
        d0 = driver#(.pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast), .fifo_depth(fifo_depth), .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r))::type_id::create("d0", this);
        m0 = monitor#(.pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast), .fifo_depth(fifo_depth), .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r))::type_id::create("m0", this);
        s0 = uvm_sequencer#(Item)::type_id::create("s0", this);

        if (!uvm_config_db#(virtual bus_if)::get(this, "", "bus_if", vif))
            `uvm_fatal("AGENT", "Could not get vif")
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        d0.seq_item_port.connect(s0.seq_item_export);       // Sequencer a Driver
        d0.item_driver_port.connect(m0.item_driver_port);          // Driver a Monitor (para expected)

        m0.m_analysis_port.connect(analysis_port);          // Monitor a Scoreboard (recibido)
        m0.expected_items.connect(expected_item_port);      // Monitor a Scoreboard (esperado) ESTE ES EL QUE NO ESTA FUNCIONANDO BIEN

        d0.vif = vif;
        m0.vif = vif;
    endfunction

endclass