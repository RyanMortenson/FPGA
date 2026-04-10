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
    "full_add/Makefile",
    "full_add/full_add.sv",
    "full_add/sim.tcl",
    "add_8/Makefile",
    "add_8/add_8.sv",
    "add_8/sim.tcl",
    "arithmetic_top/Makefile",
    "arithmetic_top/arithmetic_top.sv",
    "arithmetic_top/pre-synth-schematic.png",
    "arithmetic_top/post-synth-schematic.png",
]


def main():
    tester = test_suite_320.build_test_suite_320(
        assignment_path, start_date="02/03/2025"
    )
    tester.add_required_tracked_files(required_files)
    tester.add_makefile_rule("sim_tb", "arithmetic_top", [], ["work/sim_tb.log"])
    tester.add_build_test(
        repo_test.FileRegexCheck(
            tester, "arithmetic_top/work/sim_tb.log", "Error:", "Testbench Log Test"
        )
    )
    tester.add_makefile_rule(
        "synth", "arithmetic_top", [], ["work/synth.log", "work/synth.dcp"]
    )
    tester.add_makefile_rule(
        "implement",
        "arithmetic_top",
        [],
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
