#include <stdio.h>

/* crashtest function to force a coredump.
 * So we can test with our new section .note.gnu.source-id
 * is on the coredump or not.
 * Don't forget to call 'ulimit -c unlimited' so that a core dump can be
 * written. To open it in gdb call 'gdb demo core'.
 */
int crashtest()
{
    int *p = 0;
    *p = 5; /* dereferencing NULL pointer */
    return 0;
}

int main(int argc, char *argv[])
{
    if (argc > 1 && strcmp(argv[1], "--crash") == 0)
        crashtest();

    printf("Hello World.\n");

    return 0;
}
