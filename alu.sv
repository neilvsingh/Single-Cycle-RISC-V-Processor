module alu(
    input  logic signed [15:0] a,
    input  logic signed [15:0] b,
    input  logic [3:0] s,
    output logic signed [15:0] f,
    output logic ovf,
    output logic take_branch
);

    always_comb begin
        f = 16'd0;
        take_branch = 1'b0;
        ovf = 1'b0;

        case (s)
            4'b0000: begin
                f = a + b;
                ovf = (a[15] == b[15]) && (f[15] != a[15]);
            end
            4'b0001: f = ~b;
            4'b0010: f = a & b;
            4'b0011: f = a | b;
            4'b0100: f = a >>> b[3:0];
            4'b0101: f = a <<< b[3:0];
            4'b0110: take_branch = (a == 0);
            4'b0111: take_branch = (a != 0);
            4'b1000: f = a ^ b;
            default: begin
                f = 16'd0;
                take_branch = 1'b0;
                ovf = 1'b0;
            end
        endcase
    end

endmodule