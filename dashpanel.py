import customtkinter as CTk
from tkinter import messagebox

app = CTk.CTk()
app.title("Yeepsploit Mod Manager")
app.geometry("800x800")
domainassigned = False  # Simulating domain assignment status
filesframe = CTk.CTkFrame(app)
filesframe.pack(pady=20, padx=20, fill="both", expand=True)
FİLES_LABEL = CTk.CTkLabel(filesframe, text="Mod Files:")
FİLES_LABEL.pack(pady=10)
fileslabelarea = CTk.CTkTextbox(filesframe, width=300, height=150)
fileslabelarea.insert("0.0", "mod.ysscript")
fileslabelarea.pack()

def check():
    modfile = fileslabelarea.get("0.0", "end-1c")
    if domainassigned == True:
        messagebox.showinfo("Success", "Mod file is valid!")
    else:
        messagebox.showerror("Error", "No domain assigned! Please assign a domain before building the mod.")
buildbutton = CTk.CTkButton(app, text="Build Mod", command=lambda: check())
buildbutton.pack(pady=20)

def assign_domain():
    global domainassigned
    domainassigned = True
    messagebox.showinfo("Info", "Domain assigned successfully.")

setdomain = CTk.CTkButton(app, text="Set Domain Assigned", command=assign_domain)
setdomain.pack(pady=10)
label = CTk.CTkLabel(app, text="Yeepsploit Mod Manager v1.0")
label.pack(pady=10)
labegtl = CTk.CTkLabel(app, text="yeepsploit.org")
labegtl.pack(pady=10)
app.mainloop()