open  preamble ml_progLib fsioProgLib ml_translatorLib cfTacticsLib

val _ = new_theory "helloProg"

val _ = translation_extends"fsioProg";

val hello = process_topdecs
  `fun hello u = IO.print_string "Hello World!\n"`

val res = ml_prog_update(ml_progLib.add_prog hello pick_name)

val st = get_ml_prog_state ()

val hello_spec = Q.store_thm ("hello_spec",
  `!output.
      app (p:'ffi ffi_proj) ^(fetch_v "hello" st)
        [Conv NONE []]
        (STDIO fs * &stdout fs output)
        (POSTv uv. &UNIT_TYPE () uv * 
            (STDIO (up_stdout (output ++ "Hello World!\n") fs)) * emp)`,
  xcf "hello" st \\ xpull \\ xapp \\ xsimpl \\ instantiate \\ xsimpl);

val spec = hello_spec |> SPEC_ALL |> UNDISCH_ALL
        |> SIMP_RULE(srw_ss())[fsioConstantsProgTheory.STDIO_def]|> add_basis_proj;

val name = "hello";
val (call_thm_hello, hello_prog_tm) = call_thm st name spec;
val hello_prog_def = Define`hello_prog = ^hello_prog_tm`;

val hello_semantics = save_thm("hello_semantics",
  call_thm_hello |> ONCE_REWRITE_RULE[GSYM hello_prog_def]
  |> DISCH_ALL
  |> SIMP_RULE std_ss [APPEND,LENGTH]);

val _ = export_theory ()
