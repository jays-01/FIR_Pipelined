module n_stages_pipelined_fir #(
    parameter FIR_STAGES = 22,
    parameter DATA_WIDTH = 16,
    parameter DATA_WIDTH_F =14,
    parameter COEF_FILE_PATH = "h_bin.dat"
)(
    input clk,
    input reset,
    input signed [DATA_WIDTH-1:0] s_axis_fir_tdata,
    output reg s_axis_fir_tready,
    input s_axis_fir_tvalid,
    input s_axis_fir_tlast,
    output reg signed [DATA_WIDTH-1:0] m_axis_fir_tdata,
    input m_axis_fir_tready,
    output reg m_axis_fir_tvalid,
    output reg m_axis_fir_tlast
);

    reg signed [DATA_WIDTH-1:0] a_temp [0:FIR_STAGES];
    reg signed [DATA_WIDTH-1:0] b_temp [0:FIR_STAGES];
    reg signed [DATA_WIDTH-1:0] h_in [0:FIR_STAGES-1];
    wire signed [DATA_WIDTH-1:0] a_delay [1:FIR_STAGES];
    wire signed [DATA_WIDTH-1:0] b_delay [1:FIR_STAGES];
    reg enable;

    initial begin
        $readmemb(COEF_FILE_PATH,h_in);
        for (integer i = 0; i <= FIR_STAGES; i=i+1) begin
            a_temp[i] = 0;
            b_temp[i] = 0;
        end
    end

    always @(posedge clk) begin

        if (s_axis_fir_tlast) begin
            m_axis_fir_tlast <= 1'b1;
        end

        else begin
            m_axis_fir_tlast <= 1'b0;
        end
    end

    localparam IDLE = 1'b0;
    localparam FILTER = 1'b1;
    reg state, next_state;

    always @(*) begin
        case(state)

            IDLE: begin
                if (s_axis_fir_tvalid) begin
                    next_state <= FILTER;
                end

                else begin
                    next_state <= IDLE;
                end
            end

            FILTER: begin
                if (s_axis_fir_tvalid) begin
                    next_state <= FILTER;
                end

                else begin
                    next_state <= IDLE;
                end
            end

        endcase
    end

    always @(*) begin
        if (reset) begin
            state <= IDLE;
            m_axis_fir_tdata <= 'd0;
        end

        else begin
            state <= next_state;
            m_axis_fir_tdata <= b_temp[FIR_STAGES][DATA_WIDTH-1:0];
        end
    end

    fir_building_block #(
                .DATA_WIDTH(DATA_WIDTH),
                .DATA_WIDTH_F(DATA_WIDTH_F)
    ) instance_0 (
                    .clk(clk),
                    .reset(reset),
                    .enable(enable),
                    .a_in(a_temp[0]),
                    .b_in(b_temp[0]),
                    .a_out(a_temp[1]),
                    .b_out(b_temp[1]),
                    .h_in(h_in[0])
                    );

    assign a_delay[1] = a_temp[1];
    assign b_delay[1] = b_temp[1];

    generate // Generate filter stages
        genvar i;
        for (i = 1; i < FIR_STAGES; i = i + 1) begin : STAGE

            delay #(
                .DATA_WIDTH(DATA_WIDTH)
            ) instance_a (
                .data_in(a_temp[i]),
                .data_out(a_delay[i+1])
            );

            delay #(
                .DATA_WIDTH(DATA_WIDTH)
            ) instance_b (
                .data_in(b_temp[i]),
                .data_out(b_delay[i+1])
            );

            
            fir_building_block #(
                .DATA_WIDTH(DATA_WIDTH),
                .DATA_WIDTH_F(DATA_WIDTH_F)
            ) comp (
                    .clk(clk),
                    .reset(reset),
                    .enable(enable),
                    .a_in(a_delay[i+1]),
                    .b_in(b_delay[i+1]),
                    .a_out(a_temp[i+1]),
                    .b_out(b_temp[i+1]),
                    .h_in(h_in[i])
                    );
        end
    endgenerate

    assign b_temp[0][DATA_WIDTH-1] = 0; 
    assign a_temp[0][DATA_WIDTH-1:0] = reset?16'b0:s_axis_fir_tdata; // connect stages to FIR interface

    assign s_axis_fir_tready = (state == FILTER) && (s_axis_fir_tvalid) && (~reset);
    assign enable = (state == FILTER) && (s_axis_fir_tvalid) && (~reset);
    assign m_axis_fir_tvalid = (s_axis_fir_tvalid) && (state == FILTER) && (~reset);

endmodule