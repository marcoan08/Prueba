//interface para mesh con 1 disp
interface  bus_if #(

    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter fifo_depth=4,
    parameter id_c = 0,
    parameter id_r = 0,
    parameter columns= 4,
    parameter rows = 4
)
(
    input clk_i
);

//Entradas al DUT
    logic reset; //reset

    logic [pckg_sz-1:0]data_out_i_in[num_ntrfs-1:0]; //Datos que salen de la FIFO de salida y entran al DUT
    logic pndng_i_in[num_ntrfs-1:0]; //Señal de pending para cada terminal
    logic pop [num_ntrfs-1:0];

    //Salidas del DUT

    logic popin[num_ntrfs-1:0];
    logic pndng[num_ntrfs-1:0];
    logic [pckg_sz-1:0] data_out[num_ntrfs-1:0];

    //Preguntar en el DUT cuales señales uso para el interfaz, yo creo que así estan bien pero no se
endinterface