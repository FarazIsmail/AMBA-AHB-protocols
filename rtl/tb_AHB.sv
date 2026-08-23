module tb_AHB ();
    reg HCLK;
    reg HRESETn;
    reg [31:0] PADDR;
    reg [31:0] PWDATA;
    reg PWRITE;
    reg [2:0] PSIZE;
    reg [1:0] PTRANS;
    reg [2:0] PBURST;
    wire PDONE;
AHB_TOP uut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSIZE(PSIZE),
        .PTRANS(PTRANS),
        .PBURST(PBURST),
        .PDONE(PDONE)
);
initial begin
        HCLK = 0;
        forever #10 HCLK = ~HCLK;
end
initial begin
        HRESETn = 0;
        PADDR   = 0;
        PWDATA  = 0;
        PWRITE  = 0;
        PSIZE   = 0;
        PTRANS  = 2'b00;
        PBURST  = 0;
        #20;
        HRESETn = 1;

        PADDR   = 32'h0000_1000;
        PWRITE  = 1;
        PWDATA  = 32'hDEADBEEF;
        PSIZE   = 3'b010;
        PTRANS  = 2'b10;
        PBURST  = 3'b001;
        #40;
        PTRANS  = 2'b00;
        #20;

        PADDR   = 32'h0000_1004;
        PWRITE  = 1;
        PWDATA  = 32'hCAFEBABE;
        PSIZE   = 3'b010;
        PTRANS  = 2'b10;
        PBURST  = 3'b001;
        #40;
        PTRANS  = 2'b00;
        #20;

        PADDR   = 32'h0000_1008;
        PWRITE  = 1;
        PWDATA  = 32'h12345678;
        PSIZE   = 3'b010;
        PTRANS  = 2'b10;
        PBURST  = 3'b001;
        #40;
        PTRANS  = 2'b00;
        #40;

        PADDR   = 32'h0000_1000;
        PWRITE  = 0;
        PSIZE   = 3'b010;
        PTRANS  = 2'b10;
        PBURST  = 3'b001;
        #20;

        PADDR   = 32'h0000_1004;
        PWRITE  = 0;
        PSIZE   = 3'b010;
        PTRANS  = 2'b10;
        PBURST  = 3'b001;
        #20;

        PADDR   = 32'h0000_1008;
        PWRITE  = 0;
        PSIZE   = 3'b010;
        PTRANS  = 2'b10;
        PBURST  = 3'b001;
        #20;
        PTRANS  = 2'b00;
        #20;
        $finish;
    end
endmodule
