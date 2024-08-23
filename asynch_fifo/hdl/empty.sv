module empty #(parameter WIDTH = 3)(
    input logic [WIDTH:0] gwptr_next,
    input logic [WIDTH:0] rptr,
    output logic rempty
);

//graycode to binary for read pointer

    genvar i;
    logic [WIDTH:0] wptr_next;

    generate 
        for(i=0; i< (WIDTH + 1); i++) begin
            assign wptr_next[i] = ^(gwptr_next>>i);
        end
    endgenerate
//condition for empty
//compare binary pointers toether
    assign rempty = (rptr == wptr_next);
endmodule