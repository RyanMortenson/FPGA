import pathlib
import sys

sys.dont_write_bytecode = (
    True  # Prevent the bytecodes for the resources directory from being cached
)

# Add to the system path the "resources" directory relative to the script that was run
resources_path = pathlib.Path(__file__).resolve().parent.parent / "resources"
sys.path.append(str(resources_path))

import test_suite_320
import repo_test

assignment_path = pathlib.Path(__file__).resolve().parent

required_files = [
    "codebreaker/codebreaker.sv",
    "codebreaker_top/codebreaker_top.sv",
    "decrypt_rc4/sim.tcl",
    "decrypt_rc4/sim.png",
    "background.txt",
    "codebreaker_top/sim.tcl",
    "codebreaker_top/sim.png",
    "codebreaker_top/sim2.png",
]


def main():
    tester = test_suite_320.build_test_suite_320(assignment_path, max_repo_files=30)
    tester.add_required_tracked_files(required_files)
    tester.add_makefile_rule(
        "sim_tb", "codebreaker", ["codebreaker.sv"], ["work/sim_tb.log"]
    )
    tester.add_build_test(
        repo_test.FileRegexCheck(
            tester,
            "codebreaker/work/sim_tb.log",
            "SUCCESS: All three runs passed",
            "Codebreaker Testbench Test",
            error_on_match=False,
            error_msg="Codebreaker Testbench failed",
        )
    )
    tester.add_makefile_rule(
        "background.mem", ".", ["background.txt"], ["background.mem"]
    )
    tester.add_makefile_rule(
        "synth",
        "codebreaker_top",
        ["../codebreaker/codebreaker.sv", "codebreaker_top.sv"],
        ["work/synth.log", "work/synth.dcp"],
    )
    tester.add_makefile_rule(
        "implement",
        "codebreaker_top",
        ["work/synth.dcp"],
        [
            "work/implement.log",
            "work/design.bit",
            "work/implement.dcp",
            "work/utilization.rpt",
            "work/timing.rpt",
        ],
    )
    tester.run_tests()
    tester.exit_with_status()


if __name__ == "__main__":
    main()
