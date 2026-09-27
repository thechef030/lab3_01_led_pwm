`timescale 1ns/1ps

module button_onepulse #(
    parameter integer STABLE_CYCLES = 1_000_000
) (
    input  wire clk,
    input  wire rst_p,
    input  wire button,
    output reg  pulse
);

    (* ASYNC_REG = "TRUE" *) reg button_meta;
    (* ASYNC_REG = "TRUE" *) reg button_sync;

    localparam integer COUNT_WIDTH =
        (STABLE_CYCLES < 2) ? 1 : $clog2(STABLE_CYCLES);

    reg [COUNT_WIDTH-1:0] stable_count;
    reg accepted;

    // 2단 동기화
    always @(posedge clk or posedge rst_p) begin
        if (rst_p) begin
            button_meta <= 1'b0;
            button_sync <= 1'b0;
        end
        else begin
            button_meta <= button;
            button_sync <= button_meta;
        end
    end

    // 디바운싱 + one pulse
    always @(posedge clk or posedge rst_p) begin
        if (rst_p) begin
            stable_count <= {COUNT_WIDTH{1'b0}};
            accepted     <= 1'b0;
            pulse        <= 1'b0;
        end
        else begin
            pulse <= 1'b0;

            if (button_sync == accepted) begin
                stable_count <= {COUNT_WIDTH{1'b0}};
            end
            else if (stable_count == STABLE_CYCLES - 1) begin
                stable_count <= {COUNT_WIDTH{1'b0}};
                accepted     <= button_sync;
                pulse        <= button_sync;
            end
            else begin
                stable_count <= stable_count + 1'b1;
            end
        end
    end

endmodule
