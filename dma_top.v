`timescale 1ns/1ps

module dma_top (
input wire clk,
input wire rst,

input wire start_transfer,
input wire [31:0] source_addr,
input wire [31:0] destination_addr,
input wire [31:0] transfer_length,

input wire [31:0] memory_read_data,
input wire memory_read_done,
input wire memory_write_done,

output wire memory_read_req,
output wire memory_write_req,

output wire [31:0] memory_read_addr,
output wire [31:0] memory_write_addr,
output wire [31:0] memory_write_data,

output wire busy,
output wire done,

output reg error,
output reg interrupt,

output reg [31:0] burst_count
);

reg [31:0] data_buffer;

wire [31:0] current_src_addr;
wire [31:0] current_dst_addr;

wire bus_read_req;
wire bus_write_req;

wire transfer_done;
wire transfer_active;

wire bus_op_done;


assign bus_op_done = memory_read_done | memory_write_done;


dma_fsm u_dma_fsm (

.clk(clk),
.rst(rst),

.start_transfer(start_transfer),

.src_addr_init(source_addr),
.dst_addr_init(destination_addr),
.length_init(transfer_length),

.bus_op_done(bus_op_done),

.current_src_addr(current_src_addr),
.current_dst_addr(current_dst_addr),

.bus_read_req(bus_read_req),
.bus_write_req(bus_write_req),

.transfer_done(transfer_done),
.transfer_active(transfer_active),

.read_data_buffer(data_buffer)

);


assign memory_read_req = bus_read_req;
assign memory_write_req = bus_write_req;

assign memory_read_addr = current_src_addr;
assign memory_write_addr = current_dst_addr;

assign memory_write_data = data_buffer;

assign busy = transfer_active;
assign done = transfer_done;


always @(posedge clk or negedge rst) begin

    if (!rst)
        data_buffer <= 32'b0;

    else if (memory_read_done)
        data_buffer <= memory_read_data;

end


always @(posedge clk or negedge rst) begin

    if (!rst)
        burst_count <= 32'b0;

    else if (start_transfer)
        burst_count <= transfer_length;

    else if (memory_write_done && burst_count > 0)
        burst_count <= burst_count - 1;

end


always @(posedge clk or negedge rst) begin

    if (!rst)
        error <= 1'b0;

    else if (start_transfer) begin

        if (transfer_length == 0)
            error <= 1'b1;
        else
            error <= 1'b0;

    end

end


always @(posedge clk or negedge rst) begin

    if (!rst)
        interrupt <= 1'b0;

    else if (start_transfer)
        interrupt <= 1'b0;

    else if (transfer_done)
        interrupt <= 1'b1;

end

endmodule
