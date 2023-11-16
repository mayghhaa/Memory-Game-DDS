// 4bit comparator

module comparator_4bit (
  input wire [3:0] input1,
  input wire [3:0] input2,
  output wire equal
);

  assign equal = (input1 == input2);

endmodule

module d_flip_flop (
  input wire D,      // Data input
  input wire CLK,    // Clock input
  output reg Q      // Output
);

  //reg Q;            // Output register

  always @(posedge CLK) begin
    Q <= D;       // Data input is transferred to Q on the rising edge of the clock
  end

endmodule

module lfsr4bit (
  input wire CLK,    // Clock input
  output wire [3:0] random_number  // 4-bit random number
);

  wire feedback;
  wire [3:0] lfsr_output;

  // Instantiate four D flip-flops without reset
  d_flip_flop dff0 (.D(feedback), .CLK(CLK), .Q(lfsr_output[0]));
  d_flip_flop dff1 (.D(lfsr_output[2] ^ lfsr_output[3]), .CLK(CLK), .Q(lfsr_output[1]));
  d_flip_flop dff2 (.D(lfsr_output[1]), .CLK(CLK), .Q(lfsr_output[2]));
  d_flip_flop dff3 (.D(lfsr_output[2]), .CLK(CLK), .Q(lfsr_output[3]));

  // Feedback is XOR of the 3rd and 4th flip-flops
  assign feedback = lfsr_output[2] ^ lfsr_output[3];

  assign random_number = lfsr_output;

endmodule

module lfsr_and_storage (
  input wire CLK,        // Clock input
  output wire [0:3] random_number,  // 4-bit random number from LFSR
  output wire [0:3] stored_sequence  // 4-bit stored sequence
);

  wire [3:0] lfsr_output;
  reg [3:0] storage_output;

  // Instantiate the lfsr4bit module
  lfsr4bit lfsr (
    .CLK(CLK),
    .random_number(lfsr_output)
  );

  // Instantiate 4 flip-flops to store the sequence
  always @(posedge CLK) begin
    storage_output <= lfsr_output;
  end

  assign random_number = lfsr_output;
  assign stored_sequence = storage_output;

endmodule

module counter_1_to_2 (
  input wire CLK,    // Clock input
  output wire [1:0] count  // 2-bit counter output
);

  reg [1:0] counter;  // 2-bit counter

  always @(posedge CLK) begin
    // Increment the counter
    if (counter == 2'b01) begin
      counter <= 2'b10;
    end else begin
      counter <= 2'b01;
    end
  end

  assign count = counter;

endmodule

/*module muxes (
  input wire CLK,       // Clock input
  output wire [1:0] count, // 2-bit counter output
  output wire [0:3] mux_outputs // 4-bit multiplexer outputs
);

  reg [1:0] counter;   // 2-bit counter

  wire enable;        // Selection signal for the multiplexers

  // Instantiate the 2-bit counter module
  counter_1_to_2 counter_inst (
    .CLK(CLK),
    .count(count)
  );

  // Use one bit from the counter as the enable signal
  assign enable = count[0];

  // Instantiate 4 2:1 multiplexers
  assign mux_outputs[0] = (enable) ? stored_sequence[0] : random_number[0];
  assign mux_outputs[1] = (enable) ? stored_sequence[1] : random_number[1];
  assign mux_outputs[2] = (enable) ? stored_sequence[2] : random_number[2];
  assign mux_outputs[3] = (enable) ? stored_sequence[3] : random_number[3];

endmodule*/

module multiplexer_2to1 (
  input wire sel,          // Selection signal
  input wire data0,  // Data input 0
  input wire data1,  // Data input 1
  output wire op // Output
);

  assign op = (sel) ? data1 : data0;

endmodule


module counter_enables_muxes (
  input wire CLK,       // Clock input
  output wire [3:0] mux_outputs, // 4-bit multiplexer outputs
  input wire [3:0] lfsr_output,  // 4-bit LFSR output
  input wire [3:0] stored_sequence // 4-bit stored sequence
);

  wire [1:0] counter;   // 2-bit counter
  wire enable;         // Selection signal for the multiplexers

  // Instantiate the 2-bit counter module without reset
  counter_1_to_2 counter_inst (
    .CLK(CLK),
    .count(counter)
  );

  // Determine enable based on the counter value
  assign enable = (counter == 2'b01);

  // Instantiate 4 4:1 multiplexers
  multiplexer_2to1 mux0 ((enable),(lfsr_output[0]),(stored_sequence[0]),(mux_outputs[0]));
  multiplexer_2to1 mux1 ((enable),(lfsr_output[1]),(stored_sequence[1]),(mux_outputs[1]));
  multiplexer_2to1 mux2 ((enable),(lfsr_output[2]),(stored_sequence[2]),(mux_outputs[2]));
  multiplexer_2to1 mux3 ((enable),(lfsr_output[3]),(stored_sequence[3]),(mux_outputs[3]));

endmodule



