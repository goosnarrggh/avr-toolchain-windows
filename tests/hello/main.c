#include <avr/io.h>
int main(void)
{
    DDRB |= _BV(DDB5);
    for (;;) {
        PORTB ^= _BV(PORTB5);
    }
}
