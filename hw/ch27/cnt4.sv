// cnt4.sv

module cnt(input logic clk, rst, en, up, load, 
    input logic [3:0] count_in,
    output logic [3:0] count);

    always @(posedge clk)
        if (en)
            if (load)
                count <= count_in;
            else if (up)
                count <= count + 1;
            else
                count <= count - 1;

endmodule
