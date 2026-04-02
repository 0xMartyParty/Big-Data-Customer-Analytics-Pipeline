from flask import Flask, render_template, request
from datetime import datetime

app = Flask(__name__)

# In-memory storage for submitted age ranges.
# This lives only while the app is running.
submitted_ranges = []


@app.route("/", methods=["GET", "POST"])
def home():
    error = None
    last_range = None

    if request.method == "POST":
        # Get values from the form
        min_age_raw = request.form.get("min_age", "").strip()
        max_age_raw = request.form.get("max_age", "").strip()

        # Validate: must be integers
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
            )

        # Validate: non-negative and min <= max
        if min_age < 0 or max_age < 0 or min_age > max_age:
            error = "Please enter a valid age range (min ≤ max, both ≥ 0)."
            return render_template(
                "index.html",
                error=error,
                last_range=None,
                submitted_ranges=submitted_ranges,
            )

        # If valid, store it in memory
        last_range = {
            "min_age": min_age,
            "max_age": max_age,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        }
        submitted_ranges.append(last_range)

    # Render page for both GET and POST
    return render_template(
        "index.html",
        error=error,
        last_range=last_range,
        submitted_ranges=submitted_ranges,
    )


if __name__ == "__main__":
    app.run(host="localhost", port=8888, debug=True)
