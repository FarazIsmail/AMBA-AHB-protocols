`timescale 1ns/1ps

module tb_dma_fsm;

reg clk;
reg rst;
reg start_transfer;

reg [31:0] src_addr_init;
reg [31:0] dst_addr_init;
reg [31:0] length_init;

reg bus_op_done;
reg [31:0] read_data_buffer;

wire [31:0] current_src_addr;
wire [31:0] current_dst_addr;

wire bus_read_req;
wire bus_write_req;

wire transfer_done;
wire transfer_active;


dma_fsm dut (
    .clk(clk),
    .rst(rst),
    .start_transfer(start_transfer),
    .src_addr_init(src_addr_init),
    .dst_addr_init(dst_addr_init),
    .length_init(length_init),
    .bus_op_done(bus_op_done),
    .read_data_buffer(read_data_buffer),
    .current_src_addr(current_src_addr),
    .current_dst_addr(current_dst_addr),
    .bus_read_req(bus_read_req),
    .bus_write_req(bus_write_req),
    .transfer_done(transfer_done),
    .transfer_active(transfer_active)
);


always #5 clk = ~clk;

always @(posedge clk) begin

    if (bus_read_req || bus_write_req)
        bus_op_done <= 1'b1;
    else
        bus_op_done <= 1'b0;

end


initial begin

    clk = 0;
    rst = 0;

    start_transfer = 0;

    src_addr_init = 0;
    dst_addr_init = 0;
    length_init = 0;

    bus_op_done = 0;
    read_data_buffer = 0;

    #20;

    rst = 1;

    #10;

    src_addr_init = 32'h00001000;
    dst_addr_init = 32'h00002000;

    length_init = 3;

    start_transfer = 1;

    #10;

    start_transfer = 0;


    wait(transfer_done == 1);

    #10;

    $display("FSM");
    $display("SRC  = %h", current_src_addr);
    $display("DST  = %h", current_dst_addr);
    $display("DONE = %b", transfer_done);
    $display("BUSY = %b", transfer_active);

    if (transfer_done == 1 && transfer_active == 0)
        $display("Test Passed");
    else
        $display("Test Case Failed");

    #10;

    $finish;

end


always @(posedge clk) begin

    $display(
        "Time=%0t State=%b ReadReq=%b WriteReq=%b Active=%b Done=%b Src=%h Dst=%h Count=%d",
        $time,
        dut.state,
        bus_read_req,
        bus_write_req,
        transfer_active,
        transfer_done,
        current_src_addr,
        current_dst_addr,
        dut.transfer_count
    );

end

endmodule
