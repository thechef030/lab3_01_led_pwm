`timescale 1ns/1ps

module tb_led_pwm;

    reg clk_50mhz = 0;
    reg rst_p     = 1;
    reg button    = 0;

    wire [7:0] led;

    integer checks = 0;
    integer high_count;
    integer i;

    always #10 clk_50mhz = ~clk_50mhz;

    lab3_led_pwm #(
        .CLK_HZ(1000),
        .PWM_HZ(100),
        .LEVELS(10),
        .DEBOUNCE_CYCLES(2)
    ) dut (
        .clk_50mhz(clk_50mhz),
        .rst_p(rst_p),
        .button(button),
        .led(led)
    );

    task press_button;
    begin
        button = 1;
        repeat(6) @(posedge clk_50mhz);

        button = 0;
        repeat(6) @(posedge clk_50mhz);
    end
    endtask

    task expect_level(input integer expected);
    begin
        wait(dut.u_pwm.count == 0);

        high_count = 0;

        for(i = 0; i < 10; i = i + 1) begin
            @(posedge clk_50mhz);
            #1;

            if(led[0])
                high_count = high_count + 1;
        end

        if(high_count !== expected)
            $fatal(1,
                "level=%0d high=%0d",
                expected,
                high_count
            );

        checks = checks + 1;
    end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_led_pwm);

        repeat(3) @(posedge clk_50mhz);
        rst_p = 0;

        // 0%
        expect_level(0);

        // 버튼 3회 -> 30%
        repeat(3) press_button();
        expect_level(3);

        // 추가 7회 -> 100%
        repeat(7) press_button();
        expect_level(10);

        // 추가 1회 -> 0%
        press_button();
        expect_level(0);

        $display(
            "LAB3_LED_PWM_PASS checks=%0d",
            checks
        );

        $finish;
    end

    initial begin
        #20000;
        $fatal(1, "timeout");
    end

endmodule
