"""Exercise the built control script without changing the real display."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    helper = root / "desktop-control"
    # Substitute command dependencies while keeping the generated script body.
    helper.write_text("\n".join(
        line for line in Path(sys.argv[1]).read_text().splitlines()
        if not line.startswith("export PATH=")
    ) + "\n")
    helper.chmod(0o755)
    fake = root / "brightnessctl"
    fake.write_text("#!" + sys.executable + "\n" + '''
import json, os, sys
from pathlib import Path
p = Path(os.environ["BRIGHTNESS_TEST_STATE"])
state = json.loads(p.read_text())
args = [a for a in sys.argv[1:] if not a.startswith("--") and a != "-q"]
if args == ["get"]: print(state["current"])
elif args == ["max"]: print(state["maximum"])
elif args == ["-m"]:
    percentage = (state["current"] * 100 + state["maximum"] // 2) // state["maximum"]
    print(f"test,backlight,{state['current']},{percentage}%,{state['maximum']}")
elif len(args) == 2 and args[0] == "set":
    state["current"] = int(args[1])
    p.write_text(json.dumps(state))
else: raise SystemExit(f"Unexpected brightnessctl invocation: {sys.argv}")
''')
    fake.chmod(0o755)
    qs = root / "qs"
    # Use the same available shell as the generated helper, including in Nix builds.
    qs.write_text(helper.read_text().splitlines()[0] + "\nexit 0\n")
    qs.chmod(0o755)
    state = root / "state.json"
    env = dict(os.environ, PATH=str(root) + os.pathsep + os.environ["PATH"],
               BRIGHTNESS_TEST_STATE=str(state))
    cases = [
        (96000, 91200),  # 100 -> 95
        (14400, 9600),   # 15 -> 10
        (11520, 9600),   # 12 -> 10, do not skip the threshold
        (9600, 8640),    # 10 -> 9
        (4801, 3841),    # approximately 5 -> 4, including hardware rounding
        (960, 960),      # stop at 1%
        (480, 480),      # never brighten a panel already below the minimum
    ]
    for current, expected in cases:
        state.write_text(json.dumps({"current": current, "maximum": 96000}))
        subprocess.run([str(helper), "brightness-down"], env=env, check=True)
        actual = json.loads(state.read_text())["current"]
        assert actual == expected, (current, expected, actual)
    print(f"Passed {len(cases)} brightness boundary cases")
