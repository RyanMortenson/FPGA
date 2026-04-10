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

assignment_path = pathlib.Path(__file__).resolve().parent

required_files = [
    "Makefile",
    "binary_adder/Makefile",
    "binary_adder/sim.tcl",
    "binary_adder/sim.png",
    "binary_adder/pre-synth-schematic.png",
    "binary_adder/post-synth-schematic.png",
    "logic_functions/Makefile",
    "logic_functions/pre-synth-schematic.png",
]


def main():
    # Check on vivado
    tester = test_suite_320.build_test_suite_320(
        assignment_path, start_date="01/20/2025"
    )
    tester.add_required_tracked_files(required_files)

    tester.add_makefile_rule(
        "synth", "binary_adder", [], ["work/synth.log", "work/synth.dcp"]
    )

    tester.add_makefile_rule(
        "implement",
        "binary_adder",
        [],
        [
            "work/implement.log",
            "work/design.bit",
            "work/implement.dcp",
            "work/utilization.rpt",
        ],
    )

    tester.add_makefile_rule("sim_tb", "logic_functions", [], ["work/sim_tb.log"])
    tester.add_makefile_rule(
        "synth", "logic_functions", [], ["work/synth.log", "work/synth.dcp"]
    )
    tester.add_makefile_rule(
        "implement",
        "logic_functions",
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
