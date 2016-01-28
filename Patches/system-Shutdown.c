#include <sys/reboot.h>
int main() { reboot(RB_HALT_SYSTEM); return 0; }
