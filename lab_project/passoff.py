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

required_files = ["project_top/Makefile", "video.txt"]


def main():
    tester = test_suite_320.build_test_suite_320(assignment_path, max_repo_files=30)
    tester.add_required_tracked_files(required_files)

    tester.add_makefile_rule(
        "synth",
        "project_top",
        None,
        ["work/synth.log", "work/synth.dcp"],
    )
    tester.add_makefile_rule(
        "implement",
        "project_top",
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
