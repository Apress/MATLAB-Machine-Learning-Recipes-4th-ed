for i = 1:3
    writeline(s, "write_led 0xff");
    pause(0.5);

    writeline(s, "write_led 0x00");
    pause(0.5);
end