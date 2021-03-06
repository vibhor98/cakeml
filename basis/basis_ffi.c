#include <stdio.h>
#include <string.h>

/* stdout */

void ffiputChar (char* c, long clen, char* a) {
  putchar(a[0]);
}

// size_t is guaranteed to be at least 16 bytes.
#define WRITE_MAXLEN 65535

void ffiwriteStr (char* c, long clen, char* a) {
  fwrite(c,
         sizeof(char),
         clen <= WRITE_MAXLEN ? clen : WRITE_MAXLEN,
         stdout);
}

/* stderr */
void ffiputChar_err(char* c, long clen, char* a, long len) {
  putc(a[0], stderr);
}

/* stdin */

void ffigetChar (char* conf, long clen, char* a) {
  int c = getchar();
  if(c == EOF) {
    a[1] = 1;
  } else {
    a[0] = c;
    a[1] = 0;
  }
}

/* commandLine */

/* argc and argv are exported in cake.S */
extern int argc;
extern char **argv;

#define MAXLEN 256

void ffigetArgs (char* c, long clen, char *a) {
        int i, j, k;

        for (i = 0, k = 0; (i < argc) && (k < MAXLEN); i++, k++) {
                for (j = 0; j < strlen(argv[i]) && (k+1 < MAXLEN); j++) {
                        a[k++] = argv[i][j];
                }
        }

        return;
}

/* rofs (read-only file system) */

FILE* infds[256];

int nextFD() {
  int fd = 0;
  while(fd < 256 && infds[fd] != NULL) fd++;
  return fd;
}

void ffiopen (char* c, long clen, char *a) {
  int fd = nextFD();
  if (fd < 255 && (infds[fd] = fopen(a,"r")))
    a[0] = fd;
  else
    a[0] = 255;
}

void ffifgetc (char* conf, long clen, char *a) {
  int c; /* not char, otherwise EOF is mapped to a valid char */
  if (infds[a[0]] && (c = fgetc(infds[a[0]])) != EOF)
    a[0] = c;
  else
    a[0] = 255;
}

void fficlose (char* c, long clen, char *a) {
  if (infds[a[0]] && fclose(infds[a[0]]) == 0) {
    infds[a[0]] = NULL;
    a[0] = 1;
  }
  else
    a[0] = 0;
}

void ffiisEof (char* conf, long clen, char *a) {
  int c; /* not char, otherwise EOF is mapped to a valid char */
  if (infds[a[0]])
    if ((c = fgetc(infds[a[0]])) == EOF)
      a[0] = 1;
    else {
      ungetc(c, infds[a[0]]);
      a[0] = 0;
    }
  else
    a[0] = 255;
}
