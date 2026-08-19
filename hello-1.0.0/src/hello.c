#include <stdio.h>
#include <string.h>

#include "config.h"

/********************************************************************/
/* The standard Hello program                                       */
/* - alvinc                                                         */
/********************************************************************/

static void print_usage(void)
{
	(void) printf("Usage: %s [OPTION]\n", PROGRAM_NAME);
	(void) printf("Print 'Hello, World!' to standard output.\n\n");
	(void) printf("  -h, --help         display this help and exit\n");
	(void) printf("  -v, -V, --version  output version information and exit\n");
}

static void print_version(void)
{
	(void) printf("%s version %s\n", PROGRAM_NAME, PROGRAM_VERSION);
}

/* Main program routine                                             */

int main(int argc, char *argv[])
{
	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
			print_usage();
			return 0;
		}
		if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "-V") == 0 ||
		    strcmp(argv[i], "--version") == 0) {
			print_version();
			return 0;
		}
	}

	(void) printf("Hello, World!\n");
	return 0;
}
