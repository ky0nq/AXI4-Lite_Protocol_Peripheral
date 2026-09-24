`timescale 1ns / 1ps

module control_spi_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic       done,
    input  logic [7:0] read_data,
    output logic [7:0] load_data, 
    output logic [7:0] write_data,
    output logic [7:0] ram_data
);


    logic [7:0] ram[0:3];
    assign ram_data = ram[0];

    logic wr;
    logic [7:0] addr;
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        ADDR,
        DATA
    } con_state_e;

    con_state_e state;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            // load_data <= 0;
            write_data <= 0;
            wr <= 0;
        end else begin
            case (state)
                IDLE: begin
                    // load_data <= 0;
                    if (done) begin
                        wr <= read_data[0];
                        state <= ADDR;
                    end
                end
                ADDR: begin
                    if (done) begin
                        state <= DATA;
                        addr  <= read_data;
                    end
                end
                DATA: begin
                    if (done) begin
                        state <= IDLE;
                        if (wr) begin
                            ram[addr]  <= read_data;
                            write_data <= read_data;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    assign load_data = ram[addr];
endmodule
