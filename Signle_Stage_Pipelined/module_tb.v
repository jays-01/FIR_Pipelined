`timescale 1ns / 1ns

module firtb;

parameter FIR_STAGES = 22;
parameter xL = 2048;
parameter DATA_WIDTH = 16;
parameter DATA_WIDTH_F = 14;
parameter DATA_FILE_PATH = "inp_bin.dat";
parameter COEF_FILE_PATH = "h_bin.dat";// Coeffiecient file



reg clk;
reg reset;

wire signed [DATA_WIDTH-1:0] m_axis_fir_tdata;
wire m_axis_fir_tvalid;
wire m_axis_fir_tlast;
wire m_axis_fir_tready;
wire [DATA_WIDTH-1:0] s_axis_fir_tdata;
wire s_axis_fir_tvalid;
wire s_axis_fir_tready;
wire s_axis_fir_tlast;



fir_module_single_stage_pipelined #(
     .FIR_STAGES(FIR_STAGES), // Number of taps or filter order
     .DATA_WIDTH(DATA_WIDTH), // Input data width
     .DATA_WIDTH_F(DATA_WIDTH_F), // Fractional part width of input data
     .COEF_FILE_PATH(COEF_FILE_PATH) // Output data width
) fir_dut (
    .clk(clk), // Clock signal
    .reset(reset), // Global reset
    .s_axis_fir_tdata(s_axis_fir_tdata), // Data from sourse side of FIR filter
    //.s_axis_fir_tkeep(s_axis_fir_tkeep), // Indicates valid bytes
    .s_axis_fir_tlast(s_axis_fir_tlast), // Indicates last data beat
    .s_axis_fir_tvalid(s_axis_fir_tvalid), // Indicates valid data is avilable on the source interface
    .m_axis_fir_tready(1'b1), // Indicates 
    .m_axis_fir_tvalid(m_axis_fir_tvalid), // Indicates valid data on the master interface of FIR module
    .s_axis_fir_tready(s_axis_fir_tready), // Indicates that source is ready to accept data
    .m_axis_fir_tlast(m_axis_fir_tlast), // Indicates last beat on the master interface
    //.m_axis_fir_tkeep(m_axis_fir_tkeep), // Indicates valid bytes on the master iterface
    .m_axis_fir_tdata(m_axis_fir_tdata) // Output data
);


datasrc #(
    .xL(xL), // Data Length
    .DATA_FILE_PATH(DATA_FILE_PATH)
) src_dut(
    .clk(clk),
    .reset(reset),
    .s_axis_fir_tready(s_axis_fir_tready),
    .s_axis_fir_tvalid(s_axis_fir_tvalid),
    .s_axis_fir_tlast(s_axis_fir_tlast),
    .s_axis_fir_tdata(s_axis_fir_tdata)
);


//clock generation
always #5 clk=~clk;

integer fp_write_out;
initial  
begin
  clk = 0;
  reset = 1;
  fp_write_out = $fopen("output_rtl_vsim.csv","w");     
  #100 reset = 0;
  #1000 reset = 1;
  #20 reset = 0;

end
always @(posedge clk ) begin
  if (m_axis_fir_tvalid) begin
   $fwrite(fp_write_out,"%b\n",m_axis_fir_tdata);
   //$display("Output Written %d",m_axis_fir_tdata);
  end

  if(m_axis_fir_tlast) begin
    $fclose(fp_write_out);
  end
end
endmodule
