//Sequence_Item Mesh 1 solo disp
class Item  #(

    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter columns = 4,
    parameter rows = 4
)extends uvm_sequence_item;
    `uvm_object_utils(Item)

    //PAQUETE 
    bit [pckg_sz-1 : pckg_sz-8] nxt_jump = 0;
    rand bit [pckg_sz - 9 : pckg_sz - 12] target_row; //Esto revisarlo porque no se como hacer para que al randomizar la cantidad de 
    rand bit [pckg_sz - 13 : pckg_sz - 16] target_col; //filas y columnas y randomizar el target quede adentro del mesh 
    rand bit [pckg_sz - 17] mode;
    rand bit [pckg_sz-18 : 0] payload;
    //Puedo tengo que concatenar todo en data_in y data_out

    bit check;
    bit [pckg_sz-1 : 0] D_in; //Dato_salida
        
    //Preguntae si este input terminal va pero creo que si
    rand int input_terminal; //Esto va a llevar un constraint porque solo las terminales de entrada pueden meter datos en el mesh
    int output_terminal;
    //Variables de temporización
    rand int t_retardo;

    virtual function string convert2str();
        return $sformatf("D_in: %h, t_retardo: %0d, input_terminal: %0d, nxt_jump: %h, target_row: %0d, target_col: %0d, mode: %b, payload: %h, output_terminal: %0d",
        D_in, t_retardo, input_terminal, nxt_jump, target_row, target_col, mode, payload, output_terminal);
    endfunction

    //**************CONSTRUCTOR************************
    function new(string name = "Item");
        super.new(name);
    endfunction
    //*************************************************

    //******************Constraints*********************
    constraint const_retardo_c {t_retardo <= 25;   t_retardo > 0;}

    constraint input_terminal_c {input_terminal < num_ntrfs; input_terminal > -1;}

    constraint target_col_c { soft (target_col <= columns) && (target_col > 0);}

    constraint target_row_c { soft (target_row <= rows) && (target_row > 0); }

    constraint mode_c {mode inside {0,1};}

        //************** Verificación de Plusargs *****************
    function void check_plusargs();
        int temp_value;

        // target_row
        if ($value$plusargs("target_row=%d", temp_value)) begin
            if (temp_value > 0 && temp_value <= rows)
                target_row = temp_value;
            else
                $display("WARNING: target_row fuera de rango: %0d", temp_value);
        end

        // target_col
        if ($value$plusargs("target_col=%d", temp_value)) begin
            if (temp_value > 0 && temp_value <= columns)
                target_col = temp_value;
            else
                $display("WARNING: target_col fuera de rango: %0d", temp_value);
        end

        // mode
        if ($value$plusargs("mode=%d", temp_value)) begin
            if (temp_value == 0 || temp_value == 1)
                mode = temp_value;
            else
                $fatal("ERROR: mode solo puede ser 0 o 1, no %0d", temp_value);
        end

        // input_terminal
        if ($value$plusargs("input_terminal=%d", temp_value)) begin
            if (temp_value >= -1 && temp_value < num_ntrfs-1)
                input_terminal = temp_value;
            else
                $fatal("ERROR: input_terminal fuera de rango. Debe estar en [0, %0d), valor dado: %0d", num_ntrfs-1, temp_value);
        end
    endfunction

    // Sobreescribir post_randomize para aplicar la verificación de plusargs
    function void post_randomize();
        check_plusargs();
    endfunction

endclass