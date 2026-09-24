`timescale 1 ns / 1 ps

module spi_master_v1_0 #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
) (
    // Users to add ports here
    // output intr,
    output sclk,
    output mosi,
    output ss_n,
    input  miso,
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input  wire                                  s00_axi_aclk,
    input  wire                                  s00_axi_aresetn,
    input  wire [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input  wire [                         2 : 0] s00_axi_awprot,
    input  wire                                  s00_axi_awvalid,
    output wire                                  s00_axi_awready,
    input  wire [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input  wire                                  s00_axi_wvalid,
    output wire                                  s00_axi_wready,
    output wire [                         1 : 0] s00_axi_bresp,
    output wire                                  s00_axi_bvalid,
    input  wire                                  s00_axi_bready,
    input  wire [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input  wire [                         2 : 0] s00_axi_arprot,
    input  wire                                  s00_axi_arvalid,
    output wire                                  s00_axi_arready,
    output wire [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [                         1 : 0] s00_axi_rresp,
    output wire                                  s00_axi_rvalid,
    input  wire                                  s00_axi_rready
);

    //wire clk;
    //wire reset;
    wire       start;
    wire       cpol;
    wire       cpha;
    wire [7:0] clk_div;
    wire [7:0] tx_data;
    wire [7:0] rx_data;
    wire       busy;
    wire       done;

    // Instantiation of Axi Bus Interface S00_AXI
    spi_master_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) spi_master_v1_0_S00_AXI_inst (
        .start        (start),
        .cpol         (cpol),
        .cpha         (cpha),
        .clk_div      (clk_div),
        .tx_data      (tx_data),
        .busy         (busy),
        .done         (done),
        .rx_data      (rx_data),
        .S_AXI_ACLK   (s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR (s00_axi_awaddr),
        .S_AXI_AWPROT (s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA  (s00_axi_wdata),
        .S_AXI_WSTRB  (s00_axi_wstrb),
        .S_AXI_WVALID (s00_axi_wvalid),
        .S_AXI_WREADY (s00_axi_wready),
        .S_AXI_BRESP  (s00_axi_bresp),
        .S_AXI_BVALID (s00_axi_bvalid),
        .S_AXI_BREADY (s00_axi_bready),
        .S_AXI_ARADDR (s00_axi_araddr),
        .S_AXI_ARPROT (s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA  (s00_axi_rdata),
        .S_AXI_RRESP  (s00_axi_rresp),
        .S_AXI_RVALID (s00_axi_rvalid),
        .S_AXI_RREADY (s00_axi_rready)
    );

    // Add user logic here
    spi_master U_SPI_MASTER (
        .clk    (s00_axi_aclk),
        .reset  (~s00_axi_aresetn),
        .start  (start),
        .cpol   (cpol),
        .cpha   (cpha),
        .clk_div(clk_div),
        .tx_data(tx_data),
        .busy   (busy),
        .rx_data(rx_data),
        .done   (done),
        .sclk   (sclk),
        .mosi   (mosi),
        .miso   (miso),
        .ss_n   (ss_n)
    );
    // User logic ends

endmodule

module spi_master (
    // global signals
    input  wire       clk,
    input  wire       reset,
    // internal signals
    input  wire       start,    // cmd_start
    input  wire       cpol,     // clock polarity
    input  wire       cpha,     // clock phase
    input  wire [7:0] clk_div,  // SCLK 속도 계산용 분주값
    input  wire [7:0] tx_data,
    output reg        busy,
    output reg  [7:0] rx_data,
    output reg        done,
    // external signals
    output reg        sclk,
    output reg        mosi,
    input  wire       miso,
    output reg        ss_n
);



    // state encoding (typedef enum -> localparam)
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    reg [1:0] state;

    reg [7:0] div_cnt;
    reg [7:0] clk_div_r;
    reg       half_tick;
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [2:0] bit_cnt;
    reg       step;
    reg       cpol_r;  // 래치용
    reg       cpha_r;  // 래치용
    reg       sclk_r;  // 래치용
    // reg        miso_d1;
    // reg        miso_d2;
    // wire       miso_sync;

    // always @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         miso_d1 <= 1'b0;
    //         miso_d2 <= 1'b0;
    //     end else begin
    //         miso_d1 <= miso;
    //         miso_d2 <= miso_d1;
    //     end
    // end

    // assign miso_sync = miso_d2;

    // sclk는 reg(sclk_r)에서 구동 -> sclk도 reg로 두고 직접 대입
    // (always 안에서 sclk_r을 쓰고, 여기서 sclk에 반영)
    always @(*) begin
        sclk = sclk_r;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_cnt   <= 0;
            half_tick <= 1'b0;
        end else begin
            if (state == DATA) begin
                if (div_cnt == clk_div_r) begin
                    div_cnt   <= 0;
                    half_tick <= 1'b1;
                end else begin
                    div_cnt   <= div_cnt + 1;
                    half_tick <= 1'b0;
                end
            end else begin
                div_cnt   <= 0;
                half_tick <= 1'b0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            mosi         <= 1'b1;
            ss_n         <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
            rx_data      <= 0;
            sclk_r       <= cpol;
            cpol_r       <= 1'b0;
            cpha_r       <= 1'b0;
            clk_div_r    <= 0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    mosi   <= 1'b1;
                    ss_n   <= 1'b1;
                    sclk_r <= cpol;
                    if (start) begin
                        state        <= START;
                        cpol_r       <= cpol;
                        cpha_r       <= cpha;
                        tx_shift_reg <= tx_data;  // latching
                        clk_div_r    <= clk_div;  // latching
                        bit_cnt      <= 0;
                        busy         <= 1'b1;
                        step         <= 1'b0;
                        ss_n         <= 1'b0;
                    end
                end
                START: begin
                    if (cpha_r == 1'b0) begin
                        mosi         <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end
                    state <= DATA;
                end
                DATA: begin
                    if (half_tick) begin
                        sclk_r <= ~sclk_r;
                        if (step == 1'b0) begin  // -- 첫번째 에지
                            step <= 1'b1;
                            if (cpha_r == 1'b0) begin
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end else begin
                                mosi         <= tx_shift_reg[7];
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            end
                        end else begin  // -- 두번째 에지
                            step <= 1'b0;
                            if (cpha_r == 1'b0) begin
                                if (bit_cnt < 7) begin
                                    mosi         <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end
                            end else begin
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end
                            if (bit_cnt == 7) begin
                                state <= STOP;
                                if (cpha_r == 1'b0) begin
                                    rx_data <= rx_shift_reg;
                                end else begin
                                    rx_data <= {rx_shift_reg[6:0], miso};
                                end
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end
                    end
                end
                STOP: begin
                    done         <= 1'b1;
                    state        <= IDLE;
                    cpol_r       <= cpol;
                    cpha_r       <= cpha;
                    tx_shift_reg <= tx_data;  // latching
                    clk_div_r    <= clk_div;  // latching
                    bit_cnt      <= 0;
                    busy         <= 1'b0;
                    step         <= 1'b0;
                    ss_n         <= 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule


// module spi_master (
//     input  wire       clk,
//     input  wire       reset,
//     input  wire       start,
//     input  wire       cpol,
//     input  wire       cpha,
//     input  wire [7:0] clk_div,
//     input  wire [7:0] tx_data,
//     output reg        busy,
//     output reg  [7:0] rx_data,
//     output reg        done,
//     output reg        sclk,     // ← 레지스터 직접 출력
//     output reg        mosi,
//     input  wire       miso,
//     output reg        ss_n
// );
//     localparam IDLE = 2'b00;
//     localparam START = 2'b01;
//     localparam DATA = 2'b10;
//     localparam STOP = 2'b11;

//     reg [1:0] state;
//     reg [7:0] div_cnt;
//     reg [7:0] clk_div_r;
//     reg       half_tick;
//     reg [7:0] tx_shift_reg;
//     reg [7:0] rx_shift_reg;
//     reg [2:0] bit_cnt;
//     reg       step;
//     reg       cpol_r;
//     reg       cpha_r;
//     // reg sclk_r;  ← 제거됨

//     // always @(posedge clk or posedge reset) begin
//     //     if (reset) begin
//     //         div_cnt   <= 0;
//     //         half_tick <= 1'b0;
//     //     end else begin
//     //         half_tick <= 1'b0;

//     //         if (state == DATA) begin
//     //             if (div_cnt >= clk_div_r) begin
//     //                 div_cnt   <= 0;
//     //                 half_tick <= 1'b1;
//     //             end else begin
//     //                 div_cnt <= div_cnt + 1;
//     //             end
//     //         end else begin
//     //             div_cnt <= 0;
//     //         end
//     //     end
//     // end


//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             div_cnt   <= 0;
//             half_tick <= 1'b0;
//         end else begin
//             if (state == DATA) begin
//                 if (div_cnt == clk_div_r) begin
//                     div_cnt   <= 0;
//                     half_tick <= 1'b1;
//                 end else begin
//                     div_cnt   <= div_cnt + 1;
//                     half_tick <= 1'b0;
//                 end
//             end else begin
//                 div_cnt   <= 0;
//                 half_tick <= 1'b0;
//             end
//         end
//     end

//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             state        <= IDLE;
//             mosi         <= 1'b1;
//             ss_n         <= 1'b1;
//             busy         <= 1'b0;
//             done         <= 1'b0;
//             tx_shift_reg <= 0;
//             rx_shift_reg <= 0;
//             bit_cnt      <= 0;
//             rx_data      <= 0;
//             sclk         <= cpol; 
//             cpol_r       <= 1'b0;
//             cpha_r       <= 1'b0;
//             clk_div_r    <= 0;
//         end else begin
//             done <= 1'b0;
//             case (state)
//                 IDLE: begin
//                     mosi <= 1'b1;
//                     ss_n <= 1'b1;
//                     sclk <= cpol; 
//                     if (start) begin
//                         state        <= START;
//                         cpol_r       <= cpol;
//                         cpha_r       <= cpha;
//                         tx_shift_reg <= tx_data;
//                         clk_div_r    <= clk_div;
//                         bit_cnt      <= 0;
//                         busy         <= 1'b1;
//                         step         <= 1'b0;
//                         ss_n         <= 1'b0;
//                     end
//                 end
//                 START: begin
//                     if (cpha_r == 1'b0) begin
//                         mosi         <= tx_shift_reg[7];
//                         tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
//                     end
//                     state <= DATA;
//                 end
//                 DATA: begin
//                     if (half_tick) begin
//                         sclk <= ~sclk;       
//                         if (step == 1'b0) begin
//                             step <= 1'b1;
//                             if (cpha_r == 1'b0) begin
//                                 rx_shift_reg <= {rx_shift_reg[6:0], miso};
//                             end else begin
//                                 mosi         <= tx_shift_reg[7];
//                                 tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
//                             end
//                         end else begin
//                             step <= 1'b0;
//                             if (cpha_r == 1'b0) begin
//                                 if (bit_cnt < 7) begin
//                                     mosi         <= tx_shift_reg[7];
//                                     tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
//                                 end
//                             end else begin
//                                 rx_shift_reg <= {rx_shift_reg[6:0], miso};
//                             end
//                             if (bit_cnt == 7) begin
//                                 state <= STOP;
//                                 if (cpha_r == 1'b0) begin
//                                     rx_data <= rx_shift_reg;
//                                 end else begin
//                                     rx_data <= {rx_shift_reg[6:0], miso};
//                                 end
//                             end else begin
//                                 bit_cnt <= bit_cnt + 1;
//                             end
//                         end
//                     end
//                 end
//                 STOP: begin
//                     done         <= 1'b1;
//                     state        <= IDLE;
//                     cpol_r       <= cpol;
//                     cpha_r       <= cpha;
//                     tx_shift_reg <= tx_data;
//                     clk_div_r    <= clk_div;
//                     bit_cnt      <= 0;
//                     busy         <= 1'b0;
//                     step         <= 1'b0;
//                     ss_n         <= 1'b1;
//                 end
//                 default: state <= IDLE;
//             endcase
//         end
//     end
// endmodule

// module spi_master (
//     input  wire       clk,
//     input  wire       reset,
//     input  wire       start,
//     input  wire       cpol,
//     input  wire       cpha,
//     input  wire [7:0] clk_div,
//     input  wire [7:0] tx_data,
//     output reg        busy,
//     output reg  [7:0] rx_data,
//     output reg        done,
//     output reg        sclk,     // ← 레지스터 직접 출력
//     output reg        mosi,
//     input  wire       miso,
//     output reg        ss_n
// );
//     localparam IDLE = 2'b00;
//     localparam START = 2'b01;
//     localparam DATA = 2'b10;
//     localparam STOP = 2'b11;

//     reg [1:0] state;
//     reg [7:0] div_cnt;
//     reg [7:0] clk_div_r;
//     reg       half_tick;
//     reg [7:0] tx_shift_reg;
//     reg [7:0] rx_shift_reg;
//     reg [2:0] bit_cnt;
//     reg       step;
//     reg       cpol_r;
//     reg       cpha_r;
//     // reg sclk_r;  ← 제거됨

//     // half_tick 생성 (원본과 동일)
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             div_cnt   <= 0;
//             half_tick <= 1'b0;
//         end else begin
//             if (state == DATA) begin
//                 if (div_cnt == clk_div_r) begin
//                     div_cnt   <= 0;
//                     half_tick <= 1'b1;
//                 end else begin
//                     div_cnt   <= div_cnt + 1;
//                     half_tick <= 1'b0;
//                 end
//             end else begin
//                 div_cnt   <= 0;
//                 half_tick <= 1'b0;
//             end
//         end
//     end

//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             state        <= IDLE;
//             mosi         <= 1'b1;
//             ss_n         <= 1'b1;
//             busy         <= 1'b0;
//             done         <= 1'b0;
//             tx_shift_reg <= 0;
//             rx_shift_reg <= 0;
//             bit_cnt      <= 0;
//             rx_data      <= 0;
//             sclk         <= cpol;  // ← sclk 직접
//             cpol_r       <= 1'b0;
//             cpha_r       <= 1'b0;
//             clk_div_r    <= 0;
//         end else begin
//             done <= 1'b0;
//             case (state)
//                 IDLE: begin
//                     mosi <= 1'b1;
//                     ss_n <= 1'b1;
//                     sclk <= cpol;  // ← 직접
//                     if (start) begin
//                         state        <= START;
//                         cpol_r       <= cpol;
//                         cpha_r       <= cpha;
//                         tx_shift_reg <= tx_data;
//                         clk_div_r    <= clk_div;
//                         bit_cnt      <= 0;
//                         busy         <= 1'b1;
//                         step         <= 1'b0;
//                         ss_n         <= 1'b0;
//                     end
//                 end
//                 START: begin
//                     if (cpha_r == 1'b0) begin
//                         mosi         <= tx_shift_reg[7];
//                         tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
//                     end
//                     state <= DATA;
//                 end
//                 DATA: begin
//                     if (half_tick) begin
//                         sclk <= ~sclk;        // ← 직접 토글 (균일, 글리치 없음)
//                         if (step == 1'b0) begin
//                             step <= 1'b1;
//                             if (cpha_r == 1'b0) begin
//                                 rx_shift_reg <= {rx_shift_reg[6:0], miso};
//                             end else begin
//                                 mosi         <= tx_shift_reg[7];
//                                 tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
//                             end
//                         end else begin
//                             step <= 1'b0;
//                             if (cpha_r == 1'b0) begin
//                                 if (bit_cnt < 7) begin
//                                     mosi         <= tx_shift_reg[7];
//                                     tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
//                                 end
//                             end else begin
//                                 rx_shift_reg <= {rx_shift_reg[6:0], miso};
//                             end
//                             if (bit_cnt == 7) begin
//                                 state <= STOP;
//                                 if (cpha_r == 1'b0) begin
//                                     rx_data <= rx_shift_reg;
//                                 end else begin
//                                     rx_data <= {rx_shift_reg[6:0], miso};
//                                 end
//                             end else begin
//                                 bit_cnt <= bit_cnt + 1;
//                             end
//                         end
//                     end
//                 end
//                 STOP: begin
//                     done         <= 1'b1;
//                     state        <= IDLE;
//                     cpol_r       <= cpol;
//                     cpha_r       <= cpha;
//                     tx_shift_reg <= tx_data;
//                     clk_div_r    <= clk_div;
//                     bit_cnt      <= 0;
//                     busy         <= 1'b0;
//                     step         <= 1'b0;
//                     ss_n         <= 1'b1;
//                 end
//                 default: state <= IDLE;
//             endcase
//         end
//     end
// endmodule





