module fir_building_block #(
    parameter DATA_WIDTH = 16,
    parameter DATA_WIDTH_F = 14
)(
    input clk, // Clock Signal
    input reset, // Global reset
    input enable, // Enable signal to enable the fir
    input signed [DATA_WIDTH-1:0] a_in, 
    input signed [DATA_WIDTH-1:0] b_in,
    input signed [DATA_WIDTH-1:0] h_in,
    output reg signed [DATA_WIDTH-1:0] b_out,
    output reg signed [DATA_WIDTH-1:0] a_out
);

    reg signed [2*DATA_WIDTH-1:0] b_out_temp;

    assign b_out_temp = (a_in * h_in);

    always @(posedge clk) begin

        if(reset) begin
            a_out <= 'd0;
        end

        if (enable) begin
            a_out <= a_in;
        end
    end

    assign b_out = b_in + b_out_temp[DATA_WIDTH+DATA_WIDTH_F-1:DATA_WIDTH_F];

endmodule