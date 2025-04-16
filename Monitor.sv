class monitor #(
    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter columns = 4,
    parameter rows = 4,
    parameter id_c = 0,
    parameter id_r = 0
) extends uvm_monitor;

    `uvm_component_utils(monitor)
    int terminal_ID;
    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp  #(Item, monitor) item_driver_port;
    uvm_analysis_port #(Item) m_analysis_port;      // Datos capturados del DUT (van para el scoreboard)
    uvm_analysis_port #(Item) expected_items;
    uvm_analysis_port #(Item) item_collect_port;   // Para cobertura


    Item item_in; // Paquete que viene del driver

    virtual bus_if #(.pckg_sz(pckg_sz), .num_ntrfs(num_ntrfs), .broadcast(broadcast),
                     .columns(columns), .rows(rows), .id_c(id_c), .id_r(id_r)) vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual bus_if)::get(this, "", "bus_if", vif))
            `uvm_fatal("MON", "Could not get vif");

        //$display("Monitor del dispositivo con ID %0d", terminal_ID);
        item_driver_port = new ("item_driver_port", this);
        expected_items = new("expected_items", this);
        m_analysis_port = new("m_analysis_port", this);
        item_collect_port = new("item_collect_port", this); // Para cobertura
    endfunction

    Item expected_items_q[$];

   virtual function void write(Item expected_item);
        expected_item.check = 1;
        `uvm_info("MON", $sformatf("Monitor recibió item desde driver: D_in=%h, terminal=%0d check=%b", 
        expected_item.D_in, expected_item.input_terminal, expected_item.check), UVM_MEDIUM); //para los datos de entrada
        expected_items_q.push_back(expected_item); //Ya acá debo tener el dato del driver
    //expected_items.write(expected_item); //ESto está escribiendo siempre al recibidos del DUT en el scoreboard
    endfunction


    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            Item item = Item::type_id::create("item");
            Item esperado;
            
            @(posedge vif.clk_i);
            
            // Manejo de items esperados
            if (expected_items_q.size() > 0) begin
                esperado = expected_items_q.pop_front();
            end else begin
                esperado = Item::type_id::create("empty_item");
                esperado.D_in = 0;
            end

            for (int i = 0; i < num_ntrfs ;i++)begin
                if (vif.pndng[i]) begin
                    $display("Monitor : Detectado pndng en terminal %0d", i);
                    
                    #1; // Pequeño retardo para estabilización
                    
                    // Capturar datos
                    item.D_in = vif.data_out[i];
                    $display("Monitor %0d: Dato %0h", i, item.D_in);
                    if (item.D_in != 0) begin
                        item.nxt_jump = item.D_in[pckg_sz - 1 : pckg_sz - 8]; 
                        item.target_row = item.D_in[pckg_sz - 9 : pckg_sz - 12];
                        item.target_col = item.D_in[pckg_sz - 13 : pckg_sz - 16];
                        item.mode = item.D_in[pckg_sz - 17];
                        item.payload = item.D_in[pckg_sz - 18 : 0];
                        item.output_terminal = item.nxt_jump;
                        item.check = 0;
                        // Protocolo de handshake
                        vif.pop[i] = 1'b1;
                        @(posedge vif.clk_i);
                        vif.pop[i] = 1'b0;
                        `uvm_info("MON", $sformatf("Terminal %0d: Dato capturado D_in=%h", 
                                i, item.D_in), UVM_MEDIUM);
                        
                        // Enviar a los puertos de análisis
                        m_analysis_port.write(item);
                        item_collect_port.write(item);
                end
            end
                $display("Monitor %0d: SOLO HAY CEROS ESTA MAL %0d", i, item.D_in);
            end //else begin
                //$display("Monitor %0d: NO Detectado pndng en terminal %0d", terminal_ID, terminal_ID);
            //end

            // Enviar item esperado si es válido
            if (esperado.D_in != 0) begin
                `uvm_info("MON", $sformatf("Terminal %0d: Enviando item esperado D_in=%h", 
                        i, esperado.D_in), UVM_MEDIUM);
                m_analysis_port.write(esperado);
            end
        end
    endtask
endclass