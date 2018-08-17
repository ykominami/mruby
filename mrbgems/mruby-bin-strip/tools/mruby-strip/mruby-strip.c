#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/dump.h>

struct strip_args {
  mrb_bool lvar;
};

static void
print_usage(const char *f)
{
  printf("Usage: %s [options] irepfiles\n", f);
  printf("options:\n");
  printf("  -l, --lvar   remove LVAR section too.\n");
}

static int
parse_args(int argc, char **argv, struct strip_args *args)
{
  static const struct strip_args initial_args = {0};
  int i;

  *args = initial_args;

  for (i = 1; i < argc; ++i) {
    size_t const len = strlen(argv[i]);
    if (len >= 2 && argv[i][0] == '-') {
      switch(argv[i][1]) {
      case 'l':
        args->lvar = TRUE;
        break;
      case '-':
        if (strncmp((*argv) + 2, "lvar", len) == 0) {
          args->lvar = TRUE;
          break;
        }
      default:
        return -1;
      }
    } else {
      break;
    }
  }

  return i;
}

static int
strip(mrb_state *mrb, struct strip_args *args)
{
  int i;

  for (i = args->argc_start; i < args->argc; ++i) {
    char *filename;
    FILE *rfile;
    mrb_irep *irep;
    FILE *wfile;
    int dump_result;

    filename = args->argv[i];
    rfile = fopen(filename, "rb");
    if (rfile == NULL) {
      fprintf(stderr, "can't open file for reading %s\n", filename);
      return EXIT_FAILURE;
    }

    irep = mrb_read_irep_file(mrb, rfile);
    fclose(rfile);
    if (irep == NULL) {
      fprintf(stderr, "can't read irep file %s\n", filename);
      return EXIT_FAILURE;
    }

    /* clear lv if --lvar is enabled */
    if (args->lvar) {
      mrb_irep_remove_lv(mrb, irep);
    }

    wfile = fopen(filename, "wb");
    if (wfile == NULL) {
      fprintf(stderr, "can't open file for writing %s\n", filename);
      mrb_irep_decref(mrb, irep);
      return EXIT_FAILURE;
    }

    /* debug flag must always be false */
    dump_result = mrb_dump_irep_binary(mrb, irep, FALSE, wfile);

    fclose(wfile);
    mrb_irep_decref(mrb, irep);

    if (dump_result != MRB_DUMP_OK) {
      fprintf(stderr, "error occurred during dumping %s\n", filename);
      return EXIT_FAILURE;
    }
  }
  return EXIT_SUCCESS;
}

int
main(int argc, char **argv)
{
  struct strip_args args;
  int args_result, i, dump_result;
  FILE **files;
  mrb_irep **ireps;
  mrb_state *mrb;

  if (argc <= 1) {
    printf("no files to strip\n");
    print_usage(argv[0]);
    return EXIT_FAILURE;
  }

  args_result = parse_args(argc, argv, &args);
  if (args_result < 0) {
    print_usage(argv[0]);
    return EXIT_FAILURE;
  }

  files = (FILE**)malloc(sizeof(FILE*) * argc);
  for (i = args_result; i < argc; ++i) {
    files[i] = fopen(argv[i], "rb");

    if (!files[i]) {
      fprintf(stderr, "can't open file %s\n", argv[i]);
      return EXIT_FAILURE;
    }
  }

  mrb = mrb_open();
  if (mrb == NULL) {
    fputs("Invalid mrb_state, exiting mruby-strip\n", stderr);
    return EXIT_FAILURE;
  }

  ireps = (mrb_irep**)malloc(sizeof(mrb_irep*) * argc);
  for (i = args_result; i < argc; ++i) {
    ireps[i] = mrb_read_irep_file(mrb, files[i]);
    if (!ireps[i]) {
      fprintf(stderr, "can't read irep file %s\n", argv[i]);
      return EXIT_FAILURE;
    }
    fclose(files[i]);
    files[i] = fopen(argv[i], "wb");
    if (!ireps[i]) {
      fprintf(stderr, "can't reopen irep file %s\n", argv[i]);
      return EXIT_FAILURE;
    }
  }

  for (i = args_result; i < argc; ++i) {
    /* clear lv if --lvar is enabled */
    if (args.lvar) {
      irep_remove_lv(mrb, ireps[i]);
    }

    /* debug flag must be alway false */
    dump_result = mrb_dump_irep_binary(mrb, ireps[i], FALSE, files[i]);
    if (dump_result != MRB_DUMP_OK) {
      fprintf(stderr, "error occur when dumping %s", argv[i]);
      return EXIT_FAILURE;
    }
  }

  mrb_close(mrb);
  return EXIT_SUCCESS;
}
