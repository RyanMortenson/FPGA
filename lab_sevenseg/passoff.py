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
    "seven_segment/seven_segment.sv",
    "seven_segment_top/seven_segment_top.sv",
    "seven_segment_top/sim.tcl",
    "seven_segment_top/sim.png",
    "seven_segment_top/fpga.png",
]


def main():
    # Check on vivado
    tester = test_suite_320.build_test_suite_320(
        assignment_path, start_date="02/10/2025"
    )
    tester.add_required_tracked_files(required_files)

    tester.add_makefile_rule(
        "sim_tb", "seven_segment", ["seven_segment.sv"], ["work/sim_tb.log"]
    )
    tester.add_build_test(
        repo_test.FileRegexCheck(
            tester,
            "seven_segment/work/sim_tb.log",
            "\*\*\* Error",
            "Testbench Log Test",
        )
    )
    tester.add_makefile_rule(
        "synth", "seven_segment_top", [], ["work/synth.log", "work/synth.dcp"]
    )
    tester.add_makefile_rule(
        "implement",
        "seven_segment_top",
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
