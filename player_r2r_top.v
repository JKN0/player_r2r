// player_r2r_top.v

`timescale 1 ns / 1 ps
`default_nettype none


module player_r2r_v1_0_S00_AXI(
        // Global        
        input  wire                                     ACLK,
        input  wire                                     ARESETN,
        
        // Slave write address channel
        input  wire [32-1:0]                            AWADDR,
        input  wire [3-1:0]                             AWPROT,
        input  wire                                     AWVALID,
        output reg                                      AWREADY,
        
        // Slave write data channel
        input  wire [32-1:0]                            WDATA,
        input  wire [4-1:0]                             WSTRB,
        input  wire                                     WVALID,
        output reg                                      WREADY,
        
        // Slave write response channel
        output reg  [2-1:0]                             BRESP,
        output reg                                      BVALID,
        input  wire                                     BREADY,
        
        // Slave read address channel
        input  wire [32-1:0]                            ARADDR,
        input  wire [3-1:0]                             ARPROT,
        input  wire                                     ARVALID,
        output reg                                      ARREADY,
        
        // Slave read data channel
        output reg  [32-1:0]                            RDATA,
        output reg  [2-1:0]                             RRESP,
        output reg                                      RVALID,
        input  wire                                     RREADY,
        
        output wire [7:0]                               DAC
    );

    // Fast register file
    reg     [31:0]                                      reg_file[4095:0];
    reg     [11:0]                                      sample_ctr = 0;

    always @(posedge ACLK) begin
        if (~ARESETN) begin
            AWREADY <= 1'b0;
            WREADY <= 1'b0;
            BVALID <= 1'b0;
            ARREADY <= 1'b1;        // Always ready for read address
            RVALID <= 1'b0;
        end else begin
            // Handle write transaction, wait until both write address and data available for asserting ready signals
            if (~AWREADY && AWVALID && ~WREADY && WVALID) begin

                // reg_file[AWADDR >> ADDR_LSB] <= WDATA;
                if (WSTRB[3]) reg_file[AWADDR >> 2][32-1:24] <= WDATA[32-1:24];
                if (WSTRB[2]) reg_file[AWADDR >> 2][24-1:16] <= WDATA[24-1:16];
                if (WSTRB[1]) reg_file[AWADDR >> 2][16-1: 8] <= WDATA[16-1: 8];
                if (WSTRB[0]) reg_file[AWADDR >> 2][ 8-1: 0] <= WDATA[ 8-1: 0];
                
                AWREADY <= 1'b1;
                WREADY <= 1'b1;
                BRESP <= 2'b00; // 'OKAY' write response
                BVALID <= 1'b1;
            end else begin
                AWREADY <= 1'b0;
                WREADY <= 1'b0;
            end
                        
            // Finalize write response
            if (BREADY && BVALID) begin
                BVALID <= 1'b0;
            end
            
            // Handle read transaction, always ready for 
            if (ARREADY && ARVALID) begin
                RDATA <= { 20'd0, sample_ctr };
                RRESP <= 2'b00; // 'OKAY' read response
                RVALID <= 1'b1;
            end
            
            // Finalize read data response
            if (RREADY && RVALID) begin
                RVALID <= 1'b0;
            end
        end
    end
   
    // Generate 44.1 kHz tick
    reg [11:0] presc = 0;
    wire tick;
    
    assign tick = (presc == 12'd2267);

    always @(posedge ACLK) begin
        if (tick) begin
            presc <= 0;
        end else begin
            presc <= presc + 12'd1;
        end
    end

    // Sample counter
    always @(posedge ACLK) begin
        if (~ARESETN) begin
            sample_ctr <= 0;
        end else begin
            if (tick)
                sample_ctr <= sample_ctr + 12'd1;
        end
    end

    reg [7:0] sample;        
    always @(posedge ACLK) begin
        if (tick)
            sample <= reg_file[sample_ctr][7:0];
    end
    
    assign DAC = sample;

endmodule
