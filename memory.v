`timescale 1ns/1ps
module memory (
input wire clk,
input wire rst,

input wire read_req,
input wire [31:0] read_addr,

input wire write_req,
input wire [31:0] write_addr,
input wire [31:0] write_data,

output reg [31:0] read_data,
output reg read_done,
output reg write_done
);

reg [31:0] mem [0:4095];

always @(posedge clk or negedge rst) begin

    if (!rst) begin

        read_data <= 32'b0;
        read_done <= 1'b0;
        write_done <= 1'b0;

    end

    else begin

        read_done <= 1'b0;
        write_done <= 1'b0;

        if (read_req) begin

            read_data <= mem[read_addr >> 2];
            read_done <= 1'b1;

        end

        if (write_req) begin

            mem[write_addr >> 2] <= write_data;
            write_done <= 1'b1;

        end

    end

end

endmodule
