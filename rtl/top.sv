`timescale 1ns/1ps

module top (
    input  wire        clk_100mhz_p,
    input  wire        clk_100mhz_n,
    output wire [3:0]  led
);
    wire clk_ibuf;
    wire clk;
    logic [27:0] counter = '0;

    IBUFDS #(
        .DIFF_TERM("TRUE"),
        .IOSTANDARD("LVDS")
    ) u_clk_ibufds (
        .I(clk_100mhz_p),
        .IB(clk_100mhz_n),
        .O(clk_ibuf)
    );

    BUFG u_clk_bufg (
        .I(clk_ibuf),
        .O(clk)
    );

    always_ff @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    assign led = counter[27:24];
endmodule
