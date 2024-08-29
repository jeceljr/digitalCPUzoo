/*
 * Generated by Digital. Don't modify this file!
 * Any changes will be lost if this file is regenerated.
 */
module DIG_RegisterFile
#(
    parameter Bits = 8,
    parameter AddrBits = 4
)
(
    input [(Bits-1):0] Din,
    input we,
    input [(AddrBits-1):0] Rw,
    input C,
    input [(AddrBits-1):0] Ra,
    input [(AddrBits-1):0] Rb,
    output [(Bits-1):0] Da,
    output [(Bits-1):0] Db
);

    reg [(Bits-1):0] memory[0:((1 << AddrBits)-1)];

    assign Da = memory[Ra];
    assign Db = memory[Rb];

    always @ (posedge C) begin
        if (we)
            memory[Rw] <= Din;
    end
endmodule


module regTest (
  input clock,
  input [15:0] toRD,
  input [3:0] rD,
  input [3:0] rS1,
  input [3:0] rS2,
  input we,
  output [15:0] fromRS1,
  output [15:0] fromRS2
);
  DIG_RegisterFile #(
    .Bits(16),
    .AddrBits(4)
  )
  DIG_RegisterFile_i0 (
    .Din( toRD ),
    .we( we ),
    .Rw( rD ),
    .C( clock ),
    .Ra( rS1 ),
    .Rb( rS2 ),
    .Da( fromRS1 ),
    .Db( fromRS2 )
  );
endmodule