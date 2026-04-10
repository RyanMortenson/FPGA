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
    "seven_segment4/seven_segment4.sv",
    "ssd_top/ssd_top.sv",
    "ssd_top/basys3.xdc",
    "ssd_top/fpga.png",
]


def main():
    # Check on vivado
    tester = test_suite_320.build_test_suite_320(
        assignment_path, start_date="02/24/2025"
    )
    tester.add_required_tracked_files(required_files)
    tester.add_makefile_rule(
        "sim_tb", "seven_segment4", ["seven_segment4.sv"], ["work/sim_tb.log"]
    )
    tester.add_build_test(
        repo_test.FileRegexCheck(
            tester,
            "seven_segment4/work/sim_tb.log",
            "ERROR",
            "Testbench Log 'No Error' Test",
            error_msg="Error in testbench log",
        )
    )
    tester.add_build_test(
        repo_test.FileRegexCheck(
            tester,
            "seven_segment4/work/sim_tb.log",
            "Correct anode segment timing = ",
            "Testbench Log 'correct anode timing' test",
            error_on_match=False,
            error_msg="Incorrect anode segment timing",
        )
    )
    tester.add_makefile_rule(
        "synth",
        "ssd_top",
        ["../seven_segment4/seven_segment4.sv", "ssd_top.sv"],
        ["work/synth.log", "work/synth.dcp"],
    )
    tester.add_makefile_rule(
        "implement",
        "ssd_top",
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
