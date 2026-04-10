// cnt2.sv

module cnt(input logic clk, rst, en, up, load, 
    input logic [3:0] count_in,
    output logic [3:0] count);

    always @(posedge clk) begin
        if (rst)
            count <= 0;
        if (en) begin
            if (load)
                count <= count_in;
            if (up)
                count <= count + 1;
            else
                count <= count - 1;
        end
    end
endmodule
