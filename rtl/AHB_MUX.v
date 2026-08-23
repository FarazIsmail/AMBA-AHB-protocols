module AHB_MUX (
    input HRESP_Slave_1,
    input HREADYOUT_1,
    input [31:0] HRDATA_Slave_1,
    input HRESP_Slave_2,
    input HREADYOUT_2,
    input [31:0] HRDATA_Slave_2,
    input [1:0] HSELx_Mux,
    output reg [31:0] HRDATA,
    output reg HREADY,
    output reg HRESP
);
    always @(*) begin
        case (HSELx_Mux)
            2'b00: begin
                HRDATA = HRDATA_Slave_1;
                HREADY = HREADYOUT_1;
                HRESP = HRESP_Slave_1;
            end
            2'b01: begin
                HRDATA = HRDATA_Slave_2;
                HREADY = HREADYOUT_2;
                HRESP = HRESP_Slave_2;
            end
            default: begin
                HRDATA = 32'h00000000;
                HREADY = 1'b0;
                HRESP = 1'b0;
            end
        endcase
    end
endmodule
