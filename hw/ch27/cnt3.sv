// cnt3.sv

module cnt(input logic clk, rst, en, up, load, 
    input logic [3:0] count_in,
    output logic [3:0] count);

    always @(posedge clk) begin
        if (rst)
            count <= 0;
        if (load)
            count <= count_in;
        else if (en)
            if (up)
                count <= count + 1;
            else
                count <= count - 1;
    end
endmodule
