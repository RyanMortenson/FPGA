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
    "vga_timing/vga_timing.sv",
    "vga_top/vga_top.sv",
    "vga_top/sim.tcl",
    "vga_top/sim.png",
    "vga_top/fpga.png",
]


def main():
    # Check on vivado
    tester = test_suite_320.build_test_suite_320(
        assignment_path, start_date="03/03/2025"
    )
    tester.add_required_tracked_files(required_files)
    tester.add_makefile_rule(
        "sim_tb", "vga_timing", ["vga_timing.sv"], ["work/sim_tb.log"]
    )
    tester.add_build_test(
        repo_test.FileRegexCheck(
            tester,
            "vga_timing/work/sim_tb.log",
            "COMPLETED SUCCESSFULLY with 0 errors",
            "VGA Timing Test",
            error_on_match=False,
            error_msg="VGA Timing Test failed",
        )
    )
    tester.add_makefile_rule(
        "synth",
        "vga_top",
        ["../vga_timing/vga_timing.sv", "vga_top.sv"],
        ["work/synth.log", "work/synth.dcp"],
    )
    tester.add_makefile_rule(
        "implement",
        "vga_top",
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
