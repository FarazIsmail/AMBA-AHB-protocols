module AHB_Master (
    input HCLK,
    input HRESETn,
    input [31:0] PADDR,
    input [31:0] PWDATA,
    input PWRITE,
    input [2:0] PSIZE,
    input [1:0] PTRANS,
    input [2:0] PBURST,
    input HREADY,
    input HRESP,
    input [31:0] HRDATA,
    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    output reg HWRITE,
    output reg [2:0] HSIZE,
    output reg [1:0] HTRANS,
    output reg [2:0] HBURST,
    output reg PDONE
);

    parameter IDLE   = 2'b00,
              BUSY   = 2'b01,
              NONSEQ = 2'b10,
              SEQ    = 2'b11;

    reg [1:0] cs, ns;
    reg [31:0] HWDATA_reg;
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            cs <= IDLE;
        else
            cs <= ns;
    end

    always @(*) begin
        case (cs)

            IDLE: begin
                if (PTRANS == 2'b10)
                    ns = NONSEQ;
                else
                    ns = IDLE;
            end

            BUSY: begin
                if (PTRANS == 2'b11)
                    ns = SEQ;
                else if (PTRANS == 2'b10)
                    ns = NONSEQ;
                else if (PTRANS == 2'b00)
                    ns = IDLE;
                else
                    ns = BUSY;
            end

            NONSEQ: begin
                if (PTRANS == 2'b11)
                    ns = SEQ;
                else if (PTRANS == 2'b00)
                    ns = IDLE;
                else if ((PTRANS == 2'b10) && (PBURST == 3'b000))
                    ns = NONSEQ;
                else
                    ns = SEQ;
            end

            SEQ: begin
                if (PTRANS == 2'b00)
                    ns = IDLE;
                else if (PTRANS == 2'b10)
                    ns = NONSEQ;
                else
                    ns = SEQ;
            end

            default: ns = IDLE;

        endcase
    end
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR      <= 32'b0;
            HWDATA_reg <= 32'b0;
            HWRITE     <= 1'b0;
            HSIZE      <= 3'b000;
            HTRANS     <= 2'b00;
            HBURST     <= 3'b000;
        end
        else begin

            if (cs == IDLE) begin
                HADDR      <= 32'b0;
                HWDATA_reg <= 32'b0;
                HWRITE     <= 1'b0;
                HSIZE      <= 3'b000;
                HTRANS     <= 2'b00;
            end

            else if (cs == BUSY) begin
                HADDR      <= PADDR;
                HWDATA_reg <= PWDATA;
                HWRITE     <= PWRITE;
                HSIZE      <= PSIZE;
                HTRANS     <= PTRANS;
                HBURST     <= PBURST;
            end

            else if (cs == NONSEQ) begin
                HADDR      <= PADDR;
                HWDATA_reg <= PWDATA;
                HWRITE     <= PWRITE;
                HSIZE      <= PSIZE;
                HTRANS     <= PTRANS;
                HBURST     <= PBURST;
            end

            else if (cs == SEQ) begin

                if ((PBURST == 3'b001) && (PSIZE == 3'b000)) begin
                    HADDR      <= HADDR + 1;
                    HWDATA_reg <= {24'h000000, PWDATA[7:0]};
                    HWRITE     <= PWRITE;
                    HSIZE      <= PSIZE;
                    HTRANS     <= PTRANS;
                    HBURST     <= PBURST;
                end

                else if ((PBURST == 3'b001) && (PSIZE == 3'b001)) begin
                    HADDR      <= HADDR + 2;
                    HWDATA_reg <= {16'h0000, PWDATA[15:0]};
                    HWRITE     <= PWRITE;
                    HSIZE      <= PSIZE;
                    HTRANS     <= PTRANS;
                    HBURST     <= PBURST;
                end

                else if ((PBURST == 3'b001) && (PSIZE == 3'b010)) begin
                    HADDR      <= HADDR + 4;
                    HWDATA_reg <= PWDATA;
                    HWRITE     <= PWRITE;
                    HSIZE      <= PSIZE;
                    HTRANS     <= PTRANS;
                    HBURST     <= PBURST;
                end

                else if (PBURST == 3'b000) begin
                    HADDR      <= PADDR;
                    HWDATA_reg <= PWDATA;
                    HWRITE     <= PWRITE;
                    HSIZE      <= PSIZE;
                    HTRANS     <= PTRANS;
                    HBURST     <= PBURST;
                end

            end
        end
    end

    always @(posedge HCLK) begin
        if (HREADY)
            HWDATA <= HWDATA_reg;
    end

    always @(*) begin
        if ((cs == NONSEQ || cs == SEQ) && (ns == IDLE))
            PDONE = 1'b1;
        else
            PDONE = 1'b0;
    end

endmodule
