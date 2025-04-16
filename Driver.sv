//Driver para proyecto Mesh 1 solo disp

class driver #(
    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter fifo_depth = 4,
    parameter columns = 4,
    parameter rows = 4,
    parameter id_c = 0,
    parameter id_r = 0
)extends uvm_driver#(Item);

`uvm_component_utils(driver)

    // Puerto de análisis para enviar datos al monitor
    uvm_analysis_port #(Item) item_driver_port;

    int terminal_ID;
    function new (string name = "driver", uvm_component parent = null); //recibe el terminal de la ID el terminal lo genero en el agente con un for, se agrega el nombre y el parent.
        super.new(name, parent);
        this.fifo_send = {};
    endfunction

    virtual bus_if #(.num_ntrfs(num_ntrfs), .pckg_sz(pckg_sz), .broadcast(broadcast), .id_c(id_c), .id_r(id_r), .columns(columns), .rows(rows))vif; //puntero para la interfaz
    int counter = 0;
    int inicio = 0; // Prueba para eliminar ceros iniciales

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //Aca trata de buscar la interfaz, si no la encuentra se para el programa
        if (!uvm_config_db#(virtual bus_if)::get(this, "", "bus_if", vif))begin
            `uvm_fatal("DRV", "Could not get vif")
        end else begin
            $display("DRIVER: Interfaz obtenida con exito");
        end
        //if (!uvm_config_db#(int)::get(this, "", "terminal_id", terminal_ID)) begin
        //`uvm_fatal("DRV", "No se pudo obtener terminal_id del config_db")
        //end
        //$display("Driver del dispositivo con ID %0d", terminal_ID);
        // Crear el puerto de análisis
        item_driver_port = new("item_driver_port", this);
    endfunction

    //Colas para simular las FIFO
    logic [pckg_sz - 1 : 0] fifo_send [$]; //Una para cada dispositivo

    ////////////////////////////////////////////////
    ///////////////// Fase de Run //////////////////
    ////////////////////////////////////////////////
    virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
        //Estructura normal de UVM, agarro declaro una variable de tipo Item y lo saco del sequence item
        @(posedge vif.clk_i);
        vif.reset = '1;
        @(posedge vif.clk_i);
        vif.reset = '0;
        // Termina reseteo del sistema
        $display("Reseteo inicial del sistema [%0t]", $time);

        forever begin
            Item m_item;
            `uvm_info("DRV", $sformatf("Esperando item del secuenciador"), UVM_HIGH)
            seq_item_port.get_next_item(m_item);
            `uvm_info("DRV", $sformatf("Dato recibido del secuenciador %0h", m_item.D_in), UVM_HIGH)

            //******************************RETARDOS********************************
            if (inicio == 0) begin
                inicio = 1;
            end
            else begin
                for (int i = 1; i <= m_item.t_retardo; i++)begin // Espera el tiempo de retardo
                    @(vif.clk_i);
                end
            end
            //**********************************************************************
            drive_item(m_item);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_item(Item m_item);
        // Crear una copia del item para enviar al puerto de análisis
        Item item_clone;
        item_clone = Item::type_id::create("item_clone", this);

        //if (m_item.input_terminal == terminal_ID) begin
            //`uvm_info("DRV", $sformatf("DIRVER: Se comprueba que la entrada %0d y el ID son iguales %0d para drivear", terminal_ID, m_item.input_terminal), UVM_MEDIUM)

            if (counter >= fifo_depth) begin // La FIFO PARA METER DATOS ESTÁ LLENA 
                `uvm_fatal("DRV", "FIFO DE ENTRADA DE DATOS DEL DISP LLENA")
            end
            else begin
                fifo_send.push_back(m_item.D_in);
                counter = counter+1; 
                `uvm_info("DRV", $sformatf("DIRVER: Se agrego un dato %0h a la cola del terminal %0d", m_item.input_terminal, m_item.D_in), UVM_MEDIUM)
                vif.pndng_i_in[m_item.input_terminal] = '1;
                
                // Actualizar la copia del item con información relevante
                item_clone.D_in = m_item.D_in;
                item_clone.input_terminal = m_item.input_terminal;
                item_clone.t_retardo = m_item.t_retardo;
                
                // Enviar el item al puerto de análisis para el monitor
                item_driver_port.write(item_clone);
                `uvm_info("DRV", $sformatf("Item enviado al monitor a través del puerto de análisis: D_in=%h, terminal=%0d", 
                                        item_clone.D_in, item_clone.input_terminal), UVM_MEDIUM)
            end

            if (fifo_send.size() > 0) begin //Para meter el dato de la fifo al dispositivo
                vif.data_out_i_in[m_item.input_terminal] = fifo_send.pop_front();
                `uvm_info("DRV", $sformatf("DIRVER: Se agrego un dato al DUT desde terminal %0d : %0h", m_item.input_terminal, vif.data_out_i_in[m_item.input_terminal]), UVM_MEDIUM)
            end

            if (vif.popin [m_item.input_terminal]) begin // ESto no esta funcionando, el popin no está funcionando NINGUNA DE LA SALIDAS ESTÁ FUNCIONANDO
                if (fifo_send.size() == 0)begin
                    vif.pndng_i_in[m_item.input_terminal] = '0; // Si no hay nada en la fifo, pnding = 0
                    `uvm_info("DRV", $sformatf("Driver apago el pnding de entrada %0b", vif.pndng_i_in[m_item.input_terminal]), UVM_MEDIUM)
                end
                else begin
                    vif.pndng_i_in[m_item.input_terminal] =  vif.pndng_i_in[m_item.input_terminal]; //sino, el pnding queda como estaba
                end
            end
    
            else begin
                vif.data_out_i_in[m_item.input_terminal] = vif.data_out_i_in[m_item.input_terminal]; // Se queda igual si el pop no esta activado
            end
        //end
    endtask
endclass