//scoreboard para el mesh con un disp

class scoreboard #(
    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter fifo_depth = 4,
    parameter columns = 4,
    parameter rows = 4,
    parameter id_c = 0,
    parameter id_r = 0
) extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    uvm_analysis_imp#(Item, scoreboard) m_analysis_imp;
    uvm_analysis_imp#(Item, scoreboard) expected_items_imp;
 
    Item expected_items[$];  // Cola de paquetes esperados
    Item received_items[$];  // Cola de paquetes recibidos
    Item expected_archive[$];
    Item received_archive[$];
    int reporte;
    int min_size;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        expected_items_imp = new("expected_items_imp", this);
        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

        //Aca hay un error porque nunca estoy enviando esto 
        // Recibe los datos reales (desde el DUT)
    function void write(Item t);
        if (t.check == 0)begin
            received_items.push_back(t);
            `uvm_info("SCB", $sformatf("Recibido desde DUT: %s", t.convert2str()), UVM_MEDIUM);
            $display("DATOS RECIBIDOS DESDE EL DUT: %0d", received_items.size());
        end
        else if(t.check ==1) begin
            expected_items.push_back(t);
            `uvm_info("SCB", $sformatf("Esperado recibido: %s", t.convert2str()), UVM_MEDIUM);
            $display("DATOS RECIBIDOS DESDE EL DRIVER: %0d", expected_items.size());
        end
    endfunction

    //function void write_expected(Item t); //ESta no está haciendo nada entonces no se como implementarlo 
        //expected_items.push_back(t);
        //`uvm_info("SCB", $sformatf("Esperado recibido: %s", t.convert2str()), UVM_MEDIUM);
         //$display("DATOS RECIBIDOS DESDE EL DRIVER: %0d", expected_items.size());
    //endfunction

    virtual function void check();
        if (expected_items.size() != received_items.size()) begin
            `uvm_error("SCB", $sformatf("Las colas de esperado y recibidos no coinciden! Esperado: %0d, Recibido: %0d",
            expected_items.size(), received_items.size()));
        end
        while (expected_items.size() > 0 && received_items.size() > 0) begin
            Item expected_item = expected_items.pop_front();
            Item received_item = received_items.pop_front();
            

            // Cálculo del terminal esperado
            if (expected_item.mode == 0) begin // Modo fila
                if (expected_item.target_row > id_r) expected_item.output_terminal = 3; // Abajo
                else if (expected_item.target_row < id_r) expected_item.output_terminal = 0; // Arriba
                else expected_item.output_terminal = 4; // Local
            end else begin // Modo columna
                if (expected_item.target_col > id_c) expected_item.output_terminal = 1; // Derecha
                else if (expected_item.target_col < id_c) expected_item.output_terminal = 2; // Izquierda
                else expected_item.output_terminal = 4; // Local
            end

            // Comprobación de coincidencia
            if (expected_item.output_terminal == received_item.nxt_jump &&
                expected_item.target_row == received_item.target_row &&
                expected_item.target_col == received_item.target_col &&
                expected_item.payload == received_item.payload) begin
                `uvm_info("SCB", $sformatf("Item verificado: %s", received_item.convert2str()), UVM_HIGH);
            end else begin
                `uvm_error("SCB", $sformatf("Los item no coinciden: Esperado %s, Recibido %s", 
                    expected_item.convert2str(), received_item.convert2str()));
            end

            expected_archive.push_back(expected_item);
            received_archive.push_back(received_item);
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        reporte = $fopen("reporte.csv", "w");

        if (reporte == 0) begin
            `uvm_error("SCB", "No se pudo abrir reporte.csv");
            return;
        end

        $fwrite(reporte, "Expected Payload, Received Payload, Expected Target Row, Received Target Row, Expected Target Col, Received Target Col, Expected Terminal, Received Terminal\n");

        // Verificamos si quedaron elementos sin procesar

        // Escribimos los datos en el reporte
        min_size = (expected_archive.size() < received_archive.size()) ? expected_items.size() : received_items.size();
        for (int i = 0; i < min_size; i++) begin
            Item expected_item = expected_items[i];
            Item received_item = received_items[i];

            $fwrite(reporte, "%h, %h, %0d, %0d, %0d, %0d, %0d, %0d\n",
                     expected_item.payload, received_item.payload,
                     expected_item.target_row, received_item.target_row,
                     expected_item.target_col, received_item.target_col,
                     expected_item.output_terminal, received_item.nxt_jump);
        end

        $fclose(reporte);
        `uvm_info("SCB", "Reporte generado correctamente.", UVM_LOW);
    endfunction
endclass