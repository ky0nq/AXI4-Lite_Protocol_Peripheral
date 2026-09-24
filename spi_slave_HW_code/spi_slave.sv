`timescale 1ns / 1ps

module spi_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic       sclk,
    input  logic       mosi,
    output logic       miso,
    input  logic       ss_n,
    output logic [1:0] slave_state,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       done,
    output logic       busy
);
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START,
        DATA,
        STOP
    } state_e;
    state_e state;
    assign slave_state = state;

    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [3:0] bit_cnt;
    logic ssn_d1, ssn_d2, sclk_d1, sclk_d2;
    logic rising_sclk, falling_sclk, falling_ssn;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            sclk_d1 <= 0;
            sclk_d2 <= 0;
            ssn_d1  <= 1;
            ssn_d2  <= 1;
        end else begin
            sclk_d1 <= sclk;
            sclk_d2 <= sclk_d1;
            ssn_d1  <= ss_n;
            ssn_d2  <= ssn_d1;
        end
    end
    assign rising_sclk  = sclk_d1 & ~sclk_d2;
    assign falling_sclk = ~sclk_d1 & sclk_d2;
    assign falling_ssn  = ~ssn_d1 & ssn_d2;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            miso <= 1'b1;
            busy <= 0;
            done <= 0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt <= 0;
            rx_data <= 0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    miso <= 1'b1;
                    if (falling_ssn) begin
                        state        <= DATA;         
                        tx_shift_reg <= {tx_data[6:0], 1'b0};
                        miso <= tx_data[7];  
                        bit_cnt <= 0;
                        busy <= 1'b1;
                    end
                end
                DATA: begin
                    if (rising_sclk) begin
                        rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                        miso         <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        if (bit_cnt == 7) begin
                            state   <= STOP;
                            rx_data <= {rx_shift_reg[6:0], mosi};
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end
                STOP: begin
                    state <= IDLE;
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    miso  <= 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule