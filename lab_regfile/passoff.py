import pathlib
import sys

sys.dont_write_bytecode = (
    True  # Prevent the bytecodes for the resources directory from being cached
)

# Add to the system path the "resources" directory relative to the script that was run
resources_path = pathlib.Path(__file__).resolve().parent.parent / "resources"
sys.path.append(str(resources_path))

from repo_test_suite import RepoTestSuite
import test_suite_320
import repo_test

assignment_path = pathlib.Path(__file__).resolve().parent

required_files = [
    "reg4/Makefile",
    "reg4/reg4.sv",
    "reg4/sim.tcl",
    "reg4/sim.png",
    "regfile/Makefile",
    "regfile/regfile.sv",
    "regfile_top/Makefile",
    "regfile_top/regfile_top.sv",
    "regfile_top/basys3.xdc",
    "regfile_top/fpga.png",
]


def main():
    # Check on vivado
    tester = test_suite_320.build_test_suite_320(
        assignment_path, start_date="02/17/2025"
    )
    tester.add_required_tracked_files(required_files)
    tester.add_makefile_rule("sim_tb", "regfile", ["regfile.sv"], ["work/sim_tb.log"])
    tester.add_build_test(
        repo_test.FileRegexCheck(
            tester, "regfile/work/sim_tb.log", r"\*\*\* Error", "Testbench Log Test"
        )
    )
    tester.add_makefile_rule(
        "synth",
        "regfile_top",
        [],
        [
            "work/synth.log",
            "work/synth.dcp",
        ],
    )
    tester.add_makefile_rule(
        "implement",
        "regfile_top",
        ["work/synth.dcp"],
        [
            "work/implement.log",
            "work/design.bit",
            "work/implement.dcp",
            "work/utilization.rpt",
        ],
    )
    tester.run_tests()
    tester.exit_with_status()


if __name__ == "__main__":
    main()
