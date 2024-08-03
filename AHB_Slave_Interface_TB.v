`timescale 1ns / 1ps

module AHB_slave_interface_tb;

    reg Hclk;
    reg Hresetn;
    reg Hwrite;
    reg Hreadyin;
    reg [1:0] Htrans;
    reg [31:0] Haddr;
    reg [31:0] Hwdata;
    reg [31:0] Prdata;
    
    wire valid;
    wire [31:0] Haddr1;
    wire [31:0] Haddr2;
    wire [31:0] Hwdata1;
    wire [31:0] Hwdata2;
    wire [31:0] Hrdata;
    wire Hwritereg;
    wire [2:0] tempselx;
    wire [1:0] Hresp;
    
    // Instantiate the DUT
    AHB_slave_interface uut (
        .Hclk(Hclk), 
        .Hresetn(Hresetn), 
        .Hwrite(Hwrite), 
        .Hreadyin(Hreadyin), 
        .Htrans(Htrans), 
        .Haddr(Haddr), 
        .Hwdata(Hwdata), 
        .Prdata(Prdata), 
        .valid(valid), 
        .Haddr1(Haddr1), 
        .Haddr2(Haddr2), 
        .Hwdata1(Hwdata1), 
        .Hwdata2(Hwdata2), 
        .Hrdata(Hrdata), 
        .Hwritereg(Hwritereg), 
        .tempselx(tempselx), 
        .Hresp(Hresp)
    );
    
    // Clock generation
    initial begin
        Hclk = 0;
        forever #5 Hclk = ~Hclk; // 100MHz clock
    end
    
    // Testbench sequence
    initial begin
        // Initialize inputs
        Hresetn = 1'b0;
        Hwrite = 1'b0;
        Hreadyin = 1'b0;
        Htrans = 1'b0;
        Haddr = 1'b0;
        Hwdata = 1'b0;
        Prdata = 1'b0;

        // Wait for 100 ns for global reset to finish
        #100;
        
        // Reset sequence
        Hresetn = 1'b1;
        #10;
        
        // Test case 1: Write operation
        Hwrite = 1'b1;
        Hreadyin = 1'b1;
        Htrans = 2'b10;
        Haddr = 32'h8000_0001;
        Hwdata = 32'hDEADBEEF;
        Prdata = 32'hCAFEBABE;
        #10;
        
        // Test case 2: Read operation
        Hwrite = 1'b0;
        Haddr = 32'h8400_0002;
        #10;
        
        // Test case 3: Invalid address
        Haddr = 32'h9000_0000;
        #10;

        // Complete the simulation
        #50;
        $stop;
    end
    
endmodule

