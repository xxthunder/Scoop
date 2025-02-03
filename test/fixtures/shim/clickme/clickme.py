import sys
import tkinter as tk


def on_button_click():
    print("Button clicked!")
    app.quit()


def close_after_delay():
    print("Closing after delay")
    app.quit()


exit_code = 0

if len(sys.argv) == 2:
    try:
        exit_code = int(sys.argv[1])
    except ValueError:
        print("Invalid argument.")

app = tk.Tk()
app.title("Test GUI")
app.geometry("200x100")

button = tk.Button(app, text="Click Me", command=on_button_click)
button.pack(pady=20)

# Schedule the GUI to close after 5 seconds (5000 milliseconds)
app.after(5000, close_after_delay)

app.mainloop()
sys.exit(exit_code)
