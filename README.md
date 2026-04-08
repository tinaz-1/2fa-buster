# 🔐 2FA Buster

**2FA Buster** is a simple, fast, and user-friendly **numeric 2FA brute force tool** for educational and authorized testing purposes.  
It automatically stops when a valid code (HTTP 302) is detected and supports multi-threaded execution for speed.

> ⚠️ **Warning:** Use only on systems you are authorized to test. Do NOT use against live accounts without permission.

---

## 📌 Features

- Brute forces numeric MFA/2FA codes
- Customizable code length (`-l`)
- Multi-threaded execution (`-t`)
- Verbose/debug mode (`-v`)
- Stops automatically on valid code detection
- Clean CLI with colored output
- Beginner-friendly help menu

---

## ⚙️ Installation

Clone the repository:

```bash
git clone https://github.com/tinaz-1/2fa-buster.git
cd 2fa-buster
chmod +x 2fa.sh
