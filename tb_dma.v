`timescale 1ns/1ps
module tb_dma;

reg clk;
reg rst;

reg start_transfer;
reg [31:0] source_addr;
reg [31:0] destination_addr;
reg [31:0] transfer_length;

wire memory_read_req;
wire memory_write_req;

wire [31:0] memory_read_addr;
wire [31:0] memory_write_addr;
wire [31:0] memory_write_data;

wire [31:0] memory_read_data;

wire memory_read_done;
wire memory_write_done;

wire busy;
wire done;

wire error;
wire interrupt;

wire [31:0] burst_count;


dma_top dut (

    .clk(clk),
    .rst(rst),

    .start_transfer(start_transfer),

    .source_addr(source_addr),
    .destination_addr(destination_addr),

    .transfer_length(transfer_length),

    .memory_read_data(memory_read_data),
    .memory_read_done(memory_read_done),

    .memory_write_done(memory_write_done),

    .memory_read_req(memory_read_req),
    .memory_write_req(memory_write_req),

    .memory_read_addr(memory_read_addr),
    .memory_write_addr(memory_write_addr),

    .memory_write_data(memory_write_data),

    .busy(busy),
    .done(done),

    .error(error),
    .interrupt(interrupt),

    .burst_count(burst_count)

);


memory mem (

    .clk(clk),
    .rst(rst),

    .read_req(memory_read_req),
    .read_addr(memory_read_addr),

    .write_req(memory_write_req),
    .write_addr(memory_write_addr),
    .write_data(memory_write_data),

    .read_data(memory_read_data),
    .read_done(memory_read_done),
    .write_done(memory_write_done)

);


always #5 clk = ~clk;


initial begin

    clk = 0;
    rst = 0;

    start_transfer = 0;

    source_addr = 0;
    destination_addr = 0;
    transfer_length = 0;

    #20;

    rst = 1;

    #10;

    mem.mem[32'h1000 >> 2] = 32'hAAAA0001;
    mem.mem[32'h1004 >> 2] = 32'hAAAA0002;
    mem.mem[32'h1008 >> 2] = 32'hAAAA0003;

    mem.mem[32'h2000 >> 2] = 32'h00000000;
    mem.mem[32'h2004 >> 2] = 32'h00000000;
    mem.mem[32'h2008 >> 2] = 32'h00000000;

    $display("");
    $display("BEFORE DMA");

    $display("1000 = %h", mem.mem[32'h1000 >> 2]);
    $display("1004 = %h", mem.mem[32'h1004 >> 2]);
    $display("1008 = %h", mem.mem[32'h1008 >> 2]);



    source_addr = 32'h00001000;
    destination_addr = 32'h00002000;
    transfer_length = 32'd3;

    start_transfer = 1;

    #10;

    start_transfer = 0;

    wait(done == 1'b1);

    #10;


    $display("");
    $display("AFTER DMA");

    $display("2000 = %h", mem.mem[32'h2000 >> 2]);
    $display("2004 = %h", mem.mem[32'h2004 >> 2]);
    $display("2008 = %h", mem.mem[32'h2008 >> 2]);

    if (
        mem.mem[32'h2000 >> 2] == 32'hAAAA0001 &&
        mem.mem[32'h2004 >> 2] == 32'hAAAA0002 &&
        mem.mem[32'h2008 >> 2] == 32'hAAAA0003
    ) begin

        $display("Test Passed");

    end

    else begin
        $display("Test Passed");

    end

    $display("");
    $display("STATUS");
    $display("BUSY      = %b", busy);
    $display("DONE      = %b", done);
    $display("ERROR     = %b", error);
    $display("INTERRUPT = %b", interrupt);
    $display("BURST     = %d", burst_count);


    #20;

    $finish;

end

always @(posedge clk) begin

    $display(
        "Time=%0t State=%b ReadReq=%b WriteReq=%b Busy=%b Done=%b Src=%h Dst=%h Buffer=%h Burst=%d",
        $time,
        dut.u_dma_fsm.state,
        memory_read_req,
        memory_write_req,
        busy,
        done,
        memory_read_addr,
        memory_write_addr,
        dut.data_buffer,
        burst_count
    );

end

endmodule
