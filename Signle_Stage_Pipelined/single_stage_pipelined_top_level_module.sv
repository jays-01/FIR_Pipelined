module single_stage_pipelined_top_level_module #(
    parameter N = 11,
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

single_stage_pipelined_fir #(
	 .N(N),
    .FIR_STAGES(FIR_STAGES),
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_WIDTH_F(DATA_WIDTH_F),
    .COEF_FILE_PATH(COEF_FILE_PATH)
) fir_without_pipeline (
    .clk(clk),
    .reset(reset),
    .s_axis_fir_tdata(s_axis_fir_tdata),
    .s_axis_fir_tready(s_axis_fir_tready),
    .s_axis_fir_tvalid(s_axis_fir_tvalid),
    .s_axis_fir_tlast(s_axis_fir_tlast),
    .m_axis_fir_tdata(m_axis_fir_tdata),
    .m_axis_fir_tready(m_axis_fir_tready),
    .m_axis_fir_tvalid(m_axis_fir_tvalid),
    .m_axis_fir_tlast(m_axis_fir_tlast)
);

endmodule