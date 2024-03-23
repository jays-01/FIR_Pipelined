module datasrc #(parameter xL = 2048,
                parameter DATA_FILE_PATH = "inp_bin.dat",
                parameter DATA_WIDTH = 16,
                parameter DATA_WIDTH_F = 14
)(
    input clk,
    input reset,
    input s_axis_fir_tready,
    output s_axis_fir_tvalid,
    output s_axis_fir_tlast,
    output [15:0] s_axis_fir_tdata
    );
    
    //localparam infile = "inp_bin.dat";
    
    reg [31:0] mem[0:xL-1]; // Memory for storing input data
    localparam IDLE_STATE = 0; // State when module is idle
    localparam INIT_STATE = 1; // State for initialization tasks
    localparam READ_STATE = 2; // State for reading data from memory
    localparam WAIT_STATE = 3; // State for waiting for downstream module
    localparam END_STATE = 4; // State for end of data processing
    
    reg [2:0] state, next_state; // Current and next state
    reg [10:0] addr, next_addr; // Current and next memory address
    reg [31:0] d0, d1, d2, n_d1, n_d2; // Data registers
    reg valid, next_valid; // Valid signal registers
    
    initial $readmemb(DATA_FILE_PATH, mem); // Initialize memory with input file
    
    assign s_axis_fir_tvalid = valid; // Assign valid signal
    assign s_axis_fir_tdata = n_d2; // Assign output data
    assign s_axis_fir_tlast = (next_addr == xL - 1); // Signal last data segment
    
    always @(posedge clk) begin
        if (reset) begin
            // Reset state and registers
            state <= IDLE_STATE;
            addr <= 0;
            d0 <= 0;
            d1 <= 0;
            d2 <= 0;
            valid <= 0;
        end else begin
            // Update state and registers
            state <= next_state;
            addr <= next_addr;
            d0 <= mem[next_addr];
            d1 <= n_d1;
            d2 <= n_d2;
            valid <= next_valid;
        end
    end
    
    always @(*) begin
        // Defaults
        n_d1 = d1;
        n_d2 = d2;
        next_state = state;
        next_addr = addr;
        next_valid = valid;
        // State transition logic
        case (state)
            IDLE_STATE: begin
                // Transition to INIT_STATE
                next_addr = 0;
                next_state = INIT_STATE;
                next_valid = 0;
            end
            INIT_STATE: begin
                // Transition to READ_STATE
                n_d1 = d0;
                next_addr = 1;
                next_state = READ_STATE;
                next_valid = 1;
            end
            READ_STATE: begin
                // Stay in READ_STATE or transition to WAIT_STATE
                n_d1 = d0;
                n_d2 = d1;
                next_valid = 1;
                if (s_axis_fir_tready) begin
                    next_addr = addr + 1;  
                    next_state = READ_STATE;
                end else begin
                    next_state = WAIT_STATE;
                end
            end
            WAIT_STATE: begin
                // Stay in WAIT_STATE or transition to READ_STATE
                if (s_axis_fir_tready) begin
                    next_addr = addr + 1;
                    next_state = READ_STATE;
                end else begin
                    next_state = WAIT_STATE;
                end
            end
            END_STATE: begin
                // Transition back to IDLE_STATE
                next_state = IDLE_STATE;
            end
            
            default: begin
                // Default transition to IDLE_STATE
                next_state = IDLE_STATE;
            end
        endcase
    end
    
endmodule