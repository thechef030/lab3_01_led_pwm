`timescale 1ns/1ps

module pwm_channel #(
    parameter integer PERIOD_CYCLES = 50_000,
    parameter integer LEVELS = 10
) (
    input  wire       clk,
    input  wire       rst_p,
    input  wire [3:0] level,
    output reg        pwm
);

    localparam integer COUNT_WIDTH =
        (PERIOD_CYCLES < 2) ? 1 : $clog2(PERIOD_CYCLES);

    reg [COUNT_WIDTH-1:0] count;
    integer threshold;

    always @* begin
        if (level >= LEVELS)
            threshold = PERIOD_CYCLES;
        else
            threshold = (PERIOD_CYCLES * level) / LEVELS;
    end

    always @(posedge clk or posedge rst_p) begin
        if (rst_p) begin
            count <= {COUNT_WIDTH{1'b0}};
            pwm   <= 1'b0;
        end
        else begin
            pwm <= (count < threshold);

            if (count == PERIOD_CYCLES - 1)
                count <= {COUNT_WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end

endmodule
