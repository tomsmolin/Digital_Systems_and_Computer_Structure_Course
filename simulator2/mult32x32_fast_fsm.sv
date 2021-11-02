// 32X32 Multiplier FSM
module mult32x32_fast_fsm (
    input logic clk,              // Clock
    input logic reset,            // Reset
    input logic start,            // Start signal
    input logic a_msb_is_0,       // Indicates MSB of operand A is 0
    input logic b_msw_is_0,       // Indicates MSW of operand B is 0
    output logic busy,            // Multiplier busy indication
    output logic [1:0] a_sel,     // Select one byte from A
    output logic b_sel,           // Select one 2-byte word from B
    output logic [2:0] shift_sel, // Select output from shifters
    output logic upd_prod,        // Update the product register
    output logic clr_prod         // Clear the product register
);

typedef enum {
    idle_st,
    AC,
    AD,
    AE,
    AF,
    BC,
    BD,
    BE,
    BF
  } sm_type;

sm_type current_state;
sm_type next_state;

always_ff @(posedge clk, posedge reset) begin
    if (reset == 1'b1) begin
        current_state <= idle_st;
    end
    else begin
        current_state <= next_state;
    end
end

always_comb begin
    next_state = current_state;
    upd_prod = 1'b0;
    clr_prod = 1'b0;
    a_sel = 2'd0;
    b_sel = 1'b0;
    shift_sel = 3'b000;
    busy = 1'b0;

    case(current_state)
        idle_st: begin
            if(start == 1'b1) begin
                next_state = AC;
                clr_prod = 1'b1;   
            end 
        end   
        AC: begin
            busy = 1'b1;
            upd_prod = 1'b1;
            next_state = AD;
        end
        AD: begin
            a_sel = 2'b01;
            shift_sel = 3'b001;
            busy = 1'b1;
            upd_prod = 1'b1;
            next_state = AE;
        end
        AE: begin
            a_sel = 2'b10;
            shift_sel = 3'b010;
            busy = 1'b1;
            upd_prod = 1'b1;
            if(a_msb_is_0 == 1 && b_msw_is_0 == 0) begin
                next_state = BC;
            end else if(a_msb_is_0 == 1 && b_msw_is_0 == 1) begin
                next_state = idle_st;
            end
            else begin 
            next_state = AF;
            end
        end
        AF: begin
            a_sel = 2'b11;
            shift_sel = 3'b011;
            busy = 1'b1;
            upd_prod = 1'b1;
            if(a_msb_is_0 == 0 && b_msw_is_0 == 1) begin
                next_state = idle_st;
            end
            else begin
                next_state = BC;
            end
        end
        BC: begin
            b_sel = 1'b1;
            shift_sel = 3'b010;
            busy = 1'b1;
            upd_prod = 1'b1;
            next_state = BD;
        end
        BD: begin
            a_sel = 2'b01;
            b_sel = 1'b1;
            shift_sel = 3'b011;
            busy = 1'b1;
            upd_prod = 1'b1;
            next_state = BE;
        end
        BE: begin
            a_sel = 2'b10;
            b_sel = 1'b1;
            shift_sel = 3'b100;
            busy = 1'b1;
            upd_prod = 1'b1;
            if(a_msb_is_0 == 1 && b_msw_is_0 == 0) begin
                next_state = idle_st;
            end
            else begin
                next_state = BF;
            end
        end
        BF: begin
            a_sel = 2'b11;
            b_sel = 1'b1;
            shift_sel = 3'b101;
            busy = 1'b1;
            upd_prod = 1'b1;
            next_state = idle_st;
        end
    endcase
end
endmodule
