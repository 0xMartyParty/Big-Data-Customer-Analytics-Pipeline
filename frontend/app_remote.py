from flask import Flask, render_template, request, url_for
from datetime import datetime
import subprocess
import os

app = Flask(__name__)

# --- CONFIG: adjust these to match your setup ---
EMR_HOST = "10.99.17.21"  # your EMR master internal/public IP or DNS
EMR_USER = "hadoop"
KEY_PATH = os.path.expanduser("~/Downloads/emr-lab-key.pem")
REMOTE_SCRIPT = "/home/hadoop/spending_analyzer_2.py"
REMOTE_OUTPUT_DIR = "/home/hadoop"  # where PNGs are created on EMR
# ------------------------------------------------

# Local folder to store images so Flask can serve them
LOCAL_STATIC_DIR = os.path.join(os.path.dirname(__file__), "static")

# In-memory storage of submitted ranges (just like before)
submitted_ranges = []


def run_emr_job(min_age: int, max_age: int):
    """
    1) SSH into EMR and run spending_analyzer_2_pretty.py,
       feeding min_age and max_age as if a user typed them.
    2) scp ONLY the summary PNG back into ./static on the Mac.
    3) Return the local filename (relative to 'static') for Flask to display.
    """

    os.makedirs(LOCAL_STATIC_DIR, exist_ok=True)

    # Expected remote filename produced by your script (summary only)
    summary_remote = f"{REMOTE_OUTPUT_DIR}/spending_analysis_{min_age}_{max_age}.png"

    # 1) Run the script on EMR, feeding it the two ages via stdin
    ssh_command = f"printf '{min_age}\\n{max_age}\\n' | python3 {REMOTE_SCRIPT}"

    ssh_cmd = [
        "ssh",
        "-i",
        KEY_PATH,
        f"{EMR_USER}@{EMR_HOST}",
        ssh_command,
    ]

    result = subprocess.run(ssh_cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(
            f"Remote script failed.\nSTDOUT:\n{result.stdout}\n\nSTDERR:\n{result.stderr}"
        )

    # 2) scp the summary PNG back
    summary_local_name = f"spending_analysis_{min_age}_{max_age}.png"
    summary_local_path = os.path.join(LOCAL_STATIC_DIR, summary_local_name)

    scp_summary_cmd = [
        "scp",
        "-i",
        KEY_PATH,
        f"{EMR_USER}@{EMR_HOST}:{summary_remote}",
        summary_local_path,
    ]
    subprocess.run(scp_summary_cmd, check=True)

    return summary_local_name


@app.route("/", methods=["GET", "POST"])
def home():
    error = None
    last_range = None
    summary_image = None  # only one image now

    if request.method == "POST":
        min_age_raw = request.form.get("min_age", "").strip()
        max_age_raw = request.form.get("max_age", "").strip()

        # Validate ages
        try:
            min_age = int(min_age_raw)
            max_age = int(max_age_raw)
        except ValueError:
            error = "Ages must be whole numbers (integers)."
            return render_template(
                "index.html",
                error=error,
                last_range=None,
                submitted_ranges=submitted_ranges,
                summary_image=None,
            )

        if min_age < 0 or max_age < 0 or min_age > max_age:
            error = "Please enter a valid age range (min ≤ max, both ≥ 0)."
            return render_template(
                "index.html",
                error=error,
                last_range=None,
                submitted_ranges=submitted_ranges,
                summary_image=None,
            )

        # Store this range in memory
        last_range = {
            "min_age": min_age,
            "max_age": max_age,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        }
        submitted_ranges.append(last_range)

        # Call EMR to generate and download the summary visual
        try:
            summary_filename = run_emr_job(min_age, max_age)
            summary_image = summary_filename
        except Exception as e:
            error = f"Error running EMR job or downloading summary image: {e}"

    return render_template(
        "index.html",
        error=error,
        last_range=last_range,
        submitted_ranges=submitted_ranges,
        summary_image=summary_image,
    )


if __name__ == "__main__":
    app.run(host="localhost", port=8888, debug=True)
