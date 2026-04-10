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
    "aboutme.txt",
    "netid.png",
]


def main():
    tester = test_suite_320.build_test_suite_320(
        assignment_path, start_date="01/13/2025"
    )
    tester.add_required_tracked_files(required_files)
    tester.add_makefile_rule("about", ".", ["aboutme.txt"])
    tester.add_makefile_rule("reverse", ".", ["aboutme.txt"], ["reverse.txt"])
    # tester.add_makefile_rule("upper", ".", ["aboutme.txt"], ["upper.txt"])
    # tester.add_makefile_rule("lineno", ".", ["aboutme.txt"], ["lineno.txt"])
    tester.add_makefile_rule("bottom", ".", ["aboutme.txt"], ["bottom.txt"])
    tester.run_tests()
    tester.exit_with_status()


if __name__ == "__main__":
    main()
