`timescale 1ns/1ps

interface axi4lite_if (input logic clk);
    // Write Address Channel
    logic [3:0]  awaddr;
    logic [2:0]  awprot;
    logic        awvalid;
    logic        awready;
    // Write Data Channel
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;
    // Write Response Channel
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;
    // Read Address Channel
    logic [3:0]  araddr;
    logic [2:0]  arprot;
    logic        arvalid;
    logic        arready;
    // Read Data Channel
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rvalid;
    logic        rready;
endinterface
