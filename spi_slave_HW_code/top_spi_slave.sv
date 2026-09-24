`timescale 1ns / 1ps
module top_spi_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic       sclk,
    input  logic       mosi,
    output logic       miso,
    input  logic       ss_n 
);
    logic [7:0] w_read_data, w_write_data, w_load_data;
    logic w_done;


    control_spi_slave U_SPI_SLAVE_CONT (
        .clk(clk),
        .reset(reset),
        .done(w_done),
        .read_data(w_read_data),
        .load_data(w_load_data)  
    );

    spi_slave U_SPI_SLAVE (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n),
        .tx_data(w_load_data),
        .rx_data(w_read_data),
        .done(w_done)
    );

endmodule