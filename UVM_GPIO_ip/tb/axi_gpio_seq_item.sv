
class axi_gpio_seq_item extends uvm_sequence_item;
    `uvm_object_utils_begin(axi_gpio_seq_item)
        `uvm_field_int(addr,  UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(wstrb, UVM_ALL_ON)
        `uvm_field_int(rw,    UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(bresp, UVM_ALL_ON)
        `uvm_field_int(rresp, UVM_ALL_ON)
    `uvm_object_utils_end

    rand logic [3:0]  addr;    // 0x0=CR, 0x4=IDR, 0x8=ODR, 0xC=REG3
    rand logic [31:0] wdata;
    rand logic [3:0]  wstrb;
    rand logic        rw;      // 1=Write, 0=Read

    logic [31:0] rdata;
    logic [1:0]  bresp;
    logic [1:0]  rresp;

    constraint valid_addr_c {
        addr inside {4'h0, 4'h4, 4'h8, 4'hC};
    }

    constraint valid_wstrb_c {
        wstrb inside {4'b0001, 4'b0011, 4'b1111};
    }

    constraint idr_readonly_c {
        (addr == 4'h4) -> (rw == 1'b0);
    }

    function new(string name = "axi_gpio_seq_item");
        super.new(name);
    endfunction
endclass

