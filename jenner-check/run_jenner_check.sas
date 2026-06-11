/* run_jenner_check.sas — Jenner compatibility test runner
 *
 * Usage (from the repo root):
 *     sas -sysin jenner-check/run_jenner_check.sas -set JC_ROOT "$(pwd)"
 * or, if invoked from jenner-check/ directly:
 *     sas -sysin run_jenner_check.sas
 *
 * What it does:
 *   1. Enumerates every subdirectory of jenner-check/ whose name starts
 *      with "t" (t001_…, t002_…, …). Those are individual test bundles.
 *   2. For each bundle:
 *        a. Redirects the log and listing to bundle-local files
 *           (actual.log, actual.lst) so we can attach or diff them later.
 *        b. %includes script.sas.
 *        c. If validate.sas exists, %includes it. The validator is expected
 *           to produce a single-row dataset work.jc_validation with columns
 *           status $8 ("pass"/"fail") and message $256.
 *        d. Restores the default log + listing destinations.
 *        e. Appends one row to work.jc_results.
 *   3. Writes jenner-check/jenner_check_report.csv with one row per
 *      test and prints a summary listing.
 *
 * The test contract (what the test generator must produce in each bundle):
 *
 *     jenner-check/tNNN_name/
 *       script.sas          required   the script under test
 *       validate.sas        optional   produces work.jc_validation
 *       input/              optional   data files the script reads
 *       expected/           optional   reference output we hoped for
 *       meta.json           optional   {source_file, jenner_version, tier}
 *
 * Design notes:
 *   - Portable across UNIX and Windows SAS (no pipe/x commands).
 *   - Each test's log/listing is captured separately so the owner can ship
 *     us just the failures without leaking unrelated output.
 *   - We never fail the *runner* on a test failure. We just record it.
 *   - If validate.sas is missing we record status="no_validator" — owner can
 *     still attach the report to the PR; we treat that as "partial signal."
 */

%let JC_ROOT = %sysfunc(sysget(JC_ROOT));
%if %superq(JC_ROOT) = %str() %then %do;
    /* Default: the directory this script lives in */
    %let JC_ROOT = %sysfunc(pathname(WORK));  /* placeholder; overridden below */
    %let JC_TESTS_DIR = %sysfunc(pathname(WORK));
%end;
%else %do;
    %let JC_TESTS_DIR = &JC_ROOT/jenner-check;
%end;

/* Fallback discovery: allow invocation from the jenner-check dir itself */
%macro jc_resolve_tests_dir;
    %local candidate;
    %let candidate = &JC_TESTS_DIR;
    %if %sysfunc(fileexist(&candidate)) = 0 %then %do;
        /* Try cwd/jenner-check, then cwd */
        %let candidate = jenner-check;
        %if %sysfunc(fileexist(&candidate)) = 0 %then %let candidate = .;
    %end;
    %let JC_TESTS_DIR = &candidate;
%mend;
%jc_resolve_tests_dir;

%put NOTE: JC_TESTS_DIR = &JC_TESTS_DIR;

/* ---------- 1. Enumerate test bundle directories -------------------- */
filename jc_dir "&JC_TESTS_DIR";

data work.jc_tests;
    length test_name $64;
    rc  = filename('jcd', "&JC_TESTS_DIR");
    did = dopen('jcd');
    if did = 0 then do;
        put "ERROR: Cannot open &JC_TESTS_DIR";
        stop;
    end;
    n = dnum(did);
    do i = 1 to n;
        name = dread(did, i);
        /* Only directories whose name starts with "t" (t001_…, t002_…) */
        if substr(name, 1, 1) = 't' then do;
            child_fref = 'jcchild';
            rc2 = filename(child_fref, cats("&JC_TESTS_DIR", '/', name));
            cdid = dopen(child_fref);
            if cdid > 0 then do;
                test_name = name;
                output;
                rc2 = dclose(cdid);
            end;
            rc2 = filename(child_fref);
        end;
    end;
    rc = dclose(did);
    rc = filename('jcd');
    keep test_name;
run;

proc sort data=work.jc_tests; by test_name; run;

/* ---------- 2. Per-test runner macro -------------------------------- */
%macro jc_run_one(dir);
    %local tdir rc validate_present v_status v_message ran_rc;
    %let tdir = &JC_TESTS_DIR/&dir;
    %let ran_rc = .;
    %let v_status = ;
    %let v_message = ;

    /* Confirm script.sas exists */
    %if %sysfunc(fileexist(&tdir/script.sas)) = 0 %then %do;
        %put WARNING: &dir has no script.sas — skipping;
        data work._one;
            length test_name $64 status $32 sas_rc 8 message $256;
            test_name = "&dir"; status = "missing_script"; sas_rc = .;
            message = "no script.sas in bundle";
        run;
        proc append base=work.jc_results data=work._one force; run;
        %return;
    %end;

    /* Redirect log + listing so each test has its own actual.{log,lst} */
    proc printto log="&tdir/actual.log"
                 print="&tdir/actual.lst"
                 new;
    run;

    /* Reset &syserr before the include so we see the test's own status */
    %let syserr = 0;
    %include "&tdir/script.sas" / nosource2;
    %let ran_rc = &syserr;

    /* Validator — optional */
    %let validate_present = %sysfunc(fileexist(&tdir/validate.sas));
    %if &validate_present %then %do;
        /* Clear any prior result */
        proc datasets lib=work nolist;
            delete jc_validation / memtype=data;
        quit;
        %include "&tdir/validate.sas" / nosource2;
        %if %sysfunc(exist(work.jc_validation)) %then %do;
            data _null_;
                set work.jc_validation(obs=1);
                call symputx('v_status', status, 'L');
                call symputx('v_message', message, 'L');
            run;
        %end;
        %else %do;
            %let v_status = no_validation_output;
            %let v_message = validate.sas ran but did not produce work.jc_validation;
        %end;
    %end;
    %else %do;
        %let v_status = no_validator;
        %let v_message = no validate.sas in bundle;
    %end;

    /* Restore default destinations before we touch work.jc_results */
    proc printto; run;

    data work._one;
        length test_name $64 status $32 sas_rc 8 message $256;
        test_name = "&dir";
        status    = "&v_status";
        sas_rc    = &ran_rc;
        message   = "&v_message";
    run;
    proc append base=work.jc_results data=work._one force; run;
%mend jc_run_one;

/* ---------- 3. Initialize result table and iterate ------------------ */
data work.jc_results;
    length test_name $64 status $32 sas_rc 8 message $256;
    stop;
run;

data _null_;
    set work.jc_tests;
    call execute('%nrstr(%jc_run_one('||strip(test_name)||'));');
run;

/* ---------- 4. Emit report ----------------------------------------- */
proc export data=work.jc_results
    outfile="&JC_TESTS_DIR/jenner_check_report.csv"
    dbms=csv replace;
run;

title "Jenner Compatibility Test Results";
title2 "Report: &JC_TESTS_DIR/jenner_check_report.csv";
proc print data=work.jc_results noobs;
    var test_name status sas_rc message;
run;

data _null_;
    set work.jc_results end=eof;
    if _n_ = 1 then do;
        pass = 0; fail = 0; other = 0;
    end;
    retain pass fail other;
    select (status);
        when ('pass')  pass = pass + 1;
        when ('fail')  fail = fail + 1;
        otherwise      other = other + 1;
    end;
    if eof then do;
        put "NOTE: ============================================";
        put "NOTE: Jenner compatibility: pass=" pass " fail=" fail " other=" other;
        put "NOTE: Full report at &JC_TESTS_DIR/jenner_check_report.csv";
        put "NOTE: Please attach that CSV to the PR comment.";
        put "NOTE: ============================================";
    end;
run;
title;
title2;
