#include <stdio.h>
#include <conio.h>
#include <tgi.h>
#include <stdlib.h>
#include <string.h>

#include <api/system.h>
#include <api/uart.h>
#include <api/lcd.h>
#include <api/keyboard.h>
#include <api/wait.h>

#define SE 240
#define SB 250
#define WILL 251
#define WONT 252
#define DO 253
#define DONT 254
#define IAC 255

#define OPT_ECHO 1
#define OPT_SUPPRESS_GO_AHEAD 3
#define OPT_OUTPUT_LINE_WIDTH 8
#define OPT_OUTPUT_PAGE_SIZE 9
#define OPT_NEGOTIATE_ABOUT_WINDOW_SIZE 31

int main(int argc, char **argv);

struct flags_t {
    byte esc;
    byte echo;
    byte crlf;
    byte iac;
    byte cmd;
    byte escseq;
} flags;

char escseq_buf[64];
byte escseq_len;

/* byte buf[256]; */
/* byte bufsize; */

extern void uart_reset();

byte handle_esc_command(byte c) {
    if (c == 'q') {
        return 0;
    }
    if (c == 'e') {
        flags.echo = !flags.echo;
        if (flags.echo) {
            puts("Echo ON\n");
        } else {
            puts("Echo OFF\n");
        }
    }
    if (c == 'n') {
        flags.crlf = !flags.crlf;
        if (flags.crlf) {
            puts("CRLF on\n");
        } else {
            puts("CRLF off\n");
        }
    }
    if (c == 't') {
        puts("Sending telnet options\n");
        uart_write(IAC);
        wait1ms();
        wait1ms();
        uart_write(DO);
        wait1ms();
        wait1ms();
        uart_write(OPT_SUPPRESS_GO_AHEAD);
        wait1ms();
        wait1ms();

        uart_write(IAC);
        wait1ms();
        wait1ms();
        uart_write(WILL);
        wait1ms();
        wait1ms();
        uart_write(OPT_NEGOTIATE_ABOUT_WINDOW_SIZE);
        wait1ms();
        wait1ms();
    }
    if (c == 'd') {
        printhex(flags.esc);
        printhex(flags.echo);
        printhex(flags.crlf);
        printhex(flags.iac);
        printhex(flags.cmd);
    }
    if (c == 'c') {
        uart_write(3);
        wait1ms();
        wait1ms();
    }
    if (c == ']') {
        puts("Sending ESC\n");
        uart_write(0x1B);
        wait1ms();
        wait1ms();
    }
    flags.esc = 0;
    return 255;
}

void print(byte c) {
    /* printhex(c); */
    cputc(c);
}

int main(int argc, char **argv) {
    byte c;
    byte ret;
    byte x, y;
    char *token;

    flags.esc = 0;
    flags.echo = 1; // https://datatracker.ietf.org/doc/html/rfc857#section-3
    flags.crlf = 1;
    flags.iac = 0;
    flags.cmd = 0;
    flags.escseq = 0;

    while (1) {
        c = igetch();
        if (c == 0x1B) {
            // Enter/leave ESC mode
            flags.esc = !flags.esc;
            continue;
        }
        if (c) {
            if (flags.esc) {
                // ESC mode: Interpret user command
                ret = handle_esc_command(c);
                if (ret != 255) {
                    return ret;
                }
                continue;
            }

            if (flags.echo) {
                cputc(c);
            }
            if (c == 10 && flags.crlf) {
                uart_write(13);
                wait1ms();
                wait1ms();
                uart_write(10);
            } else {
                uart_write(c);
            }
        }
        if (uart_has_data()) {
            c = uart_get();
            if (flags.iac) {
                // Previous byte was IAC
                flags.iac = 0;
                if (c == IAC) {
                    // Got duplicate IAC, pass transparently
                    print(IAC);
                    continue;
                }
                if (c == SB) {
                    // Subnegotiation start
                    // puts("< SB ");
                    // printhex(c);
                    // cputc('\n');
                    flags.cmd = c;
                    continue;
                }
                if (c == SE) {
                    // Subnegotiation end
                    // puts("< SE\n");
                    flags.cmd = 0;
                    continue;
                }
                if (c >= WILL && c <= DONT) {
                    // puts("< WWDD\n");
                    // General command
                    flags.cmd = c;
                    continue;
                }
            }
            if (flags.cmd) {
                // In command
                if (flags.cmd >= WILL && flags.cmd <= DONT) {
                    byte *s;
                    if (flags.cmd == WILL) {
                        s = (byte *)"WILL";
                    }
                    if (flags.cmd == WONT) {
                        s = (byte *)"WONT";
                    }
                    if (flags.cmd == DO) {
                        s = (byte *)"DO";
                    }
                    if (flags.cmd == DONT) {
                        s = (byte *)"DONT";
                    }
                    // puts("< ");
                    // puts(s);
                    // cputc(' ');
                    // printhex(c);
                    // cputc('\n');
                    if (flags.cmd == DO && c == OPT_NEGOTIATE_ABOUT_WINDOW_SIZE) {
                        // Send NAWS (40xLCD_ROWS display)
                        uart_write(IAC);
                        wait1ms();
                        wait1ms();
                        uart_write(SB);
                        wait1ms();
                        wait1ms();
                        uart_write(OPT_NEGOTIATE_ABOUT_WINDOW_SIZE);
                        wait1ms();
                        wait1ms();
                        uart_write(0);
                        wait1ms();
                        wait1ms();
                        uart_write(tgi_getmaxx() + 1);
                        wait1ms();
                        wait1ms();
                        uart_write(0);
                        wait1ms();
                        wait1ms();
                        uart_write(tgi_getmaxy() + 1);
                        wait1ms();
                        wait1ms();
                        uart_write(IAC);
                        wait1ms();
                        wait1ms();
                        uart_write(SE);
                    }
                    if ((flags.cmd == WILL || flags.cmd == WONT) && c == OPT_ECHO) {
                        flags.echo = flags.cmd == WONT;
                        uart_write(IAC);
                        wait1ms();
                        wait1ms();
                        uart_write(flags.cmd == WILL ? DO : DONT);
                        wait1ms();
                        wait1ms();
                        uart_write(OPT_ECHO);
                        wait1ms();
                        wait1ms();
                    }
                    flags.cmd = 0;
                }
                continue;
            }
            // Standard data
            if (c == IAC) {
                // Received IAC
                // puts("< IAC\n");
                flags.iac = 1;
                continue;
            }
            if (c == 0x1B) {
                // Received ESC
                // puts("< ESC\n");
                flags.escseq = 1;
                escseq_len = 0;
                continue;
            }
            if (flags.escseq) {
                // In escape, parse code
                if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) {
                    // End of escape sequence reached
                    escseq_buf[escseq_len] = 0;
                    if (c == 'H' || c == 'f') {
                        // Move cursor
                        if (escseq_len > 1) {
                            token = strtok(escseq_buf + 1, ";");
                            y = atoi(token) - 1;
                            token = strtok(NULL, ";");
                            x = atoi(token) - 1;
                            gotoxy(x, y);
                            /* printhex(x); */
                            /* cputc(','); */
                            /* printhex(y); */
                            /* cputc(';'); */
                            /* while (token != NULL) { */
                            /*     atoi(token); */
                            /*     token = strtok(NULL, ";"); */
                            /* } */
                        } else {
                            gotoxy(0, 0);
                        }
                    }
                    flags.escseq = 0;
                } else {
                    escseq_buf[escseq_len++] = c;
                }
                continue;
            }
            if (c != 0) {
                // telehack.com sends these periodically
                print(c);
            }
        }
    }
    return 0;
}
