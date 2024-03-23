module delay #(
    parameter DATA_WIDTH = 16  // Width of the data bus
)(
    input clk,       // Clock input
    input reset,     // Reset input
    input signed [DATA_WIDTH-1:0] data_in,  // Input data
    output reg signed [DATA_WIDTH-1:0] data_out // Output delayed data
);

    reg [DATA_WIDTH-1:0] delay_reg;  // Initialize delay register with zeros

    initial begin
        delay_reg = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            delay_reg <= {DATA_WIDTH{1'b0}};
        end
        else begin
            delay_reg <= data_in;
        end
    end

    // Output delayed data
    assign data_out = delay_reg;

endmodule