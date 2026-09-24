`timescale 1ns/1ps
import uvm_pkg::*;
import axi_gpio_pkg::*;

module tb_top;
    logic clk;
    logic rstn;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rstn = 1'b0;
        repeat(10) @(posedge clk);
        rstn = 1'b1;
    end

    wire  [7:0] io_port;
    logic [7:0] io_drive;
    assign io_port = io_drive;
    initial io_drive = 8'bz;

    axi4lite_if axi_if(.clk(clk));

    gpio_v1_0 dut (
        .io_port          (io_port),
        .s00_axi_aclk     (clk),
        .s00_axi_aresetn  (rstn),
        .s00_axi_awaddr   (axi_if.awaddr),
        .s00_axi_awprot   (axi_if.awprot),
        .s00_axi_awvalid  (axi_if.awvalid),
        .s00_axi_awready  (axi_if.awready),
        .s00_axi_wdata    (axi_if.wdata),
        .s00_axi_wstrb    (axi_if.wstrb),
        .s00_axi_wvalid   (axi_if.wvalid),
        .s00_axi_wready   (axi_if.wready),
        .s00_axi_bresp    (axi_if.bresp),
        .s00_axi_bvalid   (axi_if.bvalid),
        .s00_axi_bready   (axi_if.bready),
        .s00_axi_araddr   (axi_if.araddr),
        .s00_axi_arprot   (axi_if.arprot),
        .s00_axi_arvalid  (axi_if.arvalid),
        .s00_axi_arready  (axi_if.arready),
        .s00_axi_rdata    (axi_if.rdata),
        .s00_axi_rresp    (axi_if.rresp),
        .s00_axi_rvalid   (axi_if.rvalid),
        .s00_axi_rready   (axi_if.rready)
    );

    initial begin
        io_drive = 8'bz;
        #2000; io_drive = 8'h5A;
        #500;  io_drive = 8'bz;
        #1000; io_drive = 8'h05;
        #500;  io_drive = 8'bz;
    end

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_top);
        uvm_config_db #(virtual axi4lite_if)::set(null, "uvm_test_top.*", "vif", axi_if);
        run_test("axi_gpio_test");
    end

    initial begin
        #1_000_000;
        `uvm_fatal("TB", "Simulation TIMEOUT")
    end
endmodule























































































































































